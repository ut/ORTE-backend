# frozen_string_literal: true

class Public::TagsController < ActionController::Base
  before_action :cors_set_access_control_headers

  protect_from_forgery with: :exception

  def index
    map = Map.published.find_by_slug(params[:map_id]) || Map.published.find_by_id(params[:map_id])
    respond_to do |format|
      if map
        if params[:layer_id]
          layer = Layer.published.find_by_slug(params[:layer_id]) || Layer.published.find_by_id(params[:layer_id])
          if layer && layer.map == map
            @places = layer.places.published
            @tags = @places.all_tags
                           .select('tags.*, COUNT(t.id) as taggings_count')
                           .joins('INNER JOIN taggings t ON t.tag_id = tags.id AND t.taggable_type = "Place"')
                           .joins('INNER JOIN places p ON p.id = t.taggable_id')
                           .joins('INNER JOIN layers l ON p.layer_id = l.id')
                           .joins('INNER JOIN maps m ON l.map_id = m.id')
                           .where('p.layer_id = ? AND p.published = true AND l.published = true AND m.published = true', layer.id)
                           .group('tags.id, tags.name')
                           .order('tags.name')
          else
            format.json { render json: { error: 'Layer not accessible' }, status: :forbidden }
          end
        else
          @places = map.places.published
          @tags = @places.all_tags
                         .select('tags.*, COUNT(t.id) as taggings_count')
                         .joins('INNER JOIN taggings t ON t.tag_id = tags.id AND t.taggable_type = "Place"')
                         .joins('INNER JOIN places p ON p.id = t.taggable_id')
                         .joins('INNER JOIN layers l ON p.layer_id = l.id')
                         .joins('INNER JOIN maps m ON l.map_id = m.id')
                         .where('l.map_id = ? AND p.published = true AND l.published = true AND m.published = true', map.id)
                         .group('tags.id, tags.name')
                         .order('tags.name')
        end
        format.json { render :index, tags: @tags }
      else
        format.json { render json: { error: 'Map not accessible' }, status: :forbidden }
      end
    end
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
end
