# frozen_string_literal: true

class Public::MapsController < ActionController::Base
  before_action :cors_set_access_control_headers

  protect_from_forgery with: :exception

  # For all responses in this controller, return the CORS access control headers.

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  # GET /maps.json
  def index
    respond_to do |format|
      format.json { render json: { error: 'No data accessible' }, status: :forbidden }
    end
  end

  # GET /maps/1.json
  def show
    @map = Map.published.find_by_slug(params[:id]) || Map.published.find_by_id(params[:id])

    respond_to do |format|
      @map_layers = @map.layers.published if @map&.layers
      if @map_layers.present?
        @map_layers = @map_layers
                      .includes(:image_attachment, places: [:icon, :annotations, :tags, { images: { file_attachment: :blob }, audio_attachment: :blob, relations_froms: %i[relation_from relation_to] }])
                      .where(places: { published: true })
        if params[:filter_by_tags]
          tags = params[:filter_by_tags].split(',')
          accordingly_tagged_place_ids = if params[:match_all].present? && params[:match_all] == 'true'
                                           Place.includes(:tags, :layer)
                                                .where(tags: { name: tags }, layer: { map: @map })
                                                .group('places.id, layer.id')
                                                .having('COUNT(DISTINCT tags.id) = ?', tags.length)
                                                .pluck(:id)
                                         else
                                           Place.includes(:tags, :layer).where(tags: { name: tags }, layer: { map: @map }).pluck(:id)
                                         end
          @map_layers = @map_layers.where(places: { id: accordingly_tagged_place_ids })
        end
        format.json { render :show, location: @map }
      elsif @map.present?
        format.json { render :show, location: @map }
      else
        format.json { render json: { error: 'Map not accessible' }, status: :forbidden }
      end
    end
  end

  # GET /maps/1/allplaces.json
  def allplaces
    @map = Map.published.find_by_slug(params[:id]) || Map.published.find_by_id(params[:id])
    respond_to do |format|
      @map_layers = @map.layers if @map&.layers
      @allplaces = []

      if @map_layers.present?
        if params[:filter_by_tags]
          tags = params[:filter_by_tags].split(',')
          filtered_place_ids = if params[:match_all].present? && params[:match_all] == 'true'
                                 Place.joins(:tags, :layer)
                                      .where(layers: { map_id: @map.id, published: true })
                                      .where(places: { published: true })
                                      .where(tags: { name: tags })
                                      .group('places.id')
                                      .having('COUNT(DISTINCT tags.id) = ?', tags.length)
                                      .pluck(:id)
                               else
                                 Place.joins(:tags, :layer)
                                      .where(layers: { map_id: @map.id, published: true })
                                      .where(places: { published: true })
                                      .where(tags: { name: tags })
                                      .distinct
                                      .pluck(:id)
                               end

          @allplaces = Place.includes(:icon, :annotations, :tags, :layer,
                                      images: { file_attachment: :blob },
                                      audio_attachment: :blob,
                                      relations_froms: %i[relation_from relation_to])
                            .where(id: filtered_place_ids)
        else
          @allplaces = Place.includes(:icon, :annotations, :tags, :layer,
                                      images: { file_attachment: :blob },
                                      audio_attachment: :blob,
                                      relations_froms: %i[relation_from relation_to])
                            .joins(:layer)
                            .where(layers: { map_id: @map.id, published: true })
                            .where(published: true)
        end
        format.json { render :allplaces, location: @map }
      else
        format.json { render json: { error: 'Map not accessible' }, status: :forbidden }
      end
    end
  end
end
