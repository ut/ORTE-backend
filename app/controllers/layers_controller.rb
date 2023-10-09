# frozen_string_literal: true

class LayersController < ApplicationController
  before_action :set_layer, only: %i[images show edit update destroy annotations relations pack build]

  before_action :redirect_to_friendly_id, only: %i[show]

  protect_from_forgery except: :show

  require 'color-generator'

  # GET /layers
  # GET /layers.json
  def index
    @map = Map.sorted.by_user(current_user).friendly.find(params[:map_id])
    @layers = @map.layers
  end

  def images
    @map = Map.sorted.by_user(current_user).friendly.find(params[:map_id])
  end

  def search
    @map = Map.sorted.by_user(current_user).friendly.find(params[:map_id])
    @layers = @map.layers
    @query = params[:q][:query]
    @places = @map.places.where('places.title LIKE :query OR places.teaser LIKE :query OR places.text LIKE :query', query: "%#{@query}%")
  end

  def pack
    @build_logs = BuildLog.where(map_id: @map.id, layer_id: @layer.id).order(created_at: :desc)
    BuildChannel.broadcast_to current_user, content: 'LayersController::pack'
  end

  def build
    if params['layer']['build']
      Build::Maptogo.new(current_user, @map, @layer).build
      head :ok
    else
      BuildChannel.broadcast_to current_user, content: 'Nothing to do...'
    end
  end

  def relations; end

  def annotations; end

  # GET /layers/1
  # GET /layers/1.json
  def show
    @maps = Map.sorted.by_user(current_user)
    redirect_to maps_path, notice: 'Sorry, this map could not be found.' and return unless @map

    @map_layers = @map.layers

    if @layer
      if @layer.map && @layer.use_background_from_parent_map && @layer.map.basemap_url && @layer.map.background_color
        @layer.basemap_url = @layer.map.basemap_url
        @layer.basemap_attribution = @layer.map.basemap_attribution
        @layer.background_color = @layer.map.background_color
      end
      @places = @layer.places
      @place = Place.find(params[:place_id]) if params[:remap]
      respond_to do |format|
        format.html { render :show }
        format.json { render :show }
        format.csv { send_data @places.to_csv, filename: "orte-map-#{@layer.map.title.parameterize}-layer-#{@layer.title.parameterize}-#{I18n.l Date.today}.csv" }
      end
    else
      redirect_to maps_path, notice: 'Sorry, this layer could not be found.'
    end
  end

  # GET /layers/new
  def new
    @layer = Layer.new
    generator = ColorGenerator.new saturation: 0.8, lightness: 0.7
    @layer.color = "##{generator.create_hex}"
    @layer.ltype = 'image' if params[:ltype] == 'image'
    @map = Map.by_user(current_user).friendly.find(params[:map_id])
    @colors_selectable = []
    6.times do
      @colors_selectable << "##{generator.create_hex}"
    end
  end

  # GET /layers/1/edit
  def edit
    generator = ColorGenerator.new saturation: 0.8, lightness: 0.7
    if !@layer.color || params[:recolor]
      @layer.color = "##{generator.create_hex}"
    elsif @layer.color && !@layer.color.include?('#')
      @layer.color = "##{@layer.color}"
    end
    @colors_selectable = []
    6.times do
      @colors_selectable << "##{generator.create_hex}"
    end

    @layer.use_background_from_parent_map = false unless @layer.map.basemap_url && @layer.map.basemap_attribution && @layer.map.background_color

    if @layer.map && @layer.use_background_from_parent_map && @layer.map.basemap_url && @layer.map.background_color
      @layer.basemap_url = @layer.map.basemap_url
      @layer.basemap_attribution = @layer.map.basemap_attribution
      @layer.background_color = @layer.map.background_color
    end

    @layer.use_mapcenter_from_parent_map = false unless @layer.map.mapcenter_lat && @layer.map.mapcenter_lon && @layer.map.zoom

    return unless @layer.use_mapcenter_from_parent_map && @layer.map.mapcenter_lat && @layer.map.mapcenter_lon && @layer.map.zoom

    @layer.mapcenter_lat = @layer.map.mapcenter_lat
    @layer.mapcenter_lon = @layer.map.mapcenter_lon
    @layer.zoom = @layer.map.zoom
  end

  # POST /layers
  # POST /layers.json
  def create
    @layer = Layer.new(layer_params)
    @layer.color = "##{@layer.color}" if @layer.color && !@layer.color.include?('#')
    @map = Map.by_user(current_user).friendly.find(params[:map_id])
    respond_to do |format|
      if @layer.ltype == 'image'
        @layer.exif_remove = false
        if validate_images_format
          created_places, skipped_images = create_places_with_exif_data
          flash[:alert] = "The following #{skipped_images.count} images were not created due to missing GPSLatitude data: #{skipped_images.join(', ')}" if skipped_images&.any?
          if @layer.save && created_places && created_places.any?
            format.html { redirect_to map_layer_path(@map, @layer), notice: "Layer was created with #{created_places.count} geocoded images." }
            format.json { render :show, status: :created, location: @layer }
          else
            flash[:alert] << 'No places with geodata has been found. Or some other error occured.'
            format.html { render :new }
            format.json { render json: @layer.errors, status: :unprocessable_entity }
          end
        else
          flash[:alert] = 'This is an image layer, but no images has been provided.'
          format.html { render :new }
          format.json { render json: @layer.errors, status: :unprocessable_entity }
        end
      elsif @layer.save
        format.html { redirect_to map_layer_path(@map, @layer), notice: 'Layer was created.' }
        format.json { render :show, status: :created, location: @layer }
      else
        format.html { render :new }
        format.json { render json: @layer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /layers/1
  # PATCH/PUT /layers/1.json
  def update
    @layer.color = "##{@layer.color}" if @layer.color && !@layer.color.include?('#')
    params[:layer][:exif_remove] = default_checkbox(params[:layer][:exif_remove])
    params[:layer][:rasterize_images] = default_checkbox(params[:layer][:rasterize_images])

    respond_to do |format|
      if @layer.ltype == 'image' && validate_images_format
        created_places, skipped_images = create_places_with_exif_data
        flash[:alert] = "The following #{skipped_images.count} images were not created due to missing GPSLatitude data: #{skipped_images.join(', ')}" if skipped_images&.any?
        if @layer.update(layer_params) && created_places && created_places.any?
          format.html { redirect_to map_layer_path(@map, @layer), notice: "Layer was updated with #{created_places.count} new geocoded images." }
          format.json { render :show, status: :created, location: @layer }
        else
          flash[:alert] << 'No places with geodata has been found. Or some other error occured.'
          format.html { render :new }
          format.json { render json: @layer.errors, status: :unprocessable_entity }
        end
      elsif @layer.update(layer_params)
        format.html { redirect_to map_layer_path(@map, @layer), notice: 'Layer was successfully updated.' }
        format.json { render :show, status: :ok, location: @layer }
      else
        format.html { render :edit }
        format.json { render json: @layer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /layers/1
  # DELETE /layers/1.json
  def destroy
    @layer.destroy
    respond_to do |format|
      format.html { redirect_to map_path(@map), notice: 'Layer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def build_params
    params.require(:layer).permit(:content, :build)
  end

  def redirect_to_friendly_id
    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
    redirect_to map_layer_path(@map, @layer), status: :moved_permanently if @map && @layer && request.path != map_layer_path(@map, @layer) && request.format == 'html'
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_layer
    @map = Map.by_user(current_user).find_by_slug(params[:map_id]) || Map.by_user(current_user).find_by_id(params[:map_id])
    @layer = Layer.find_by_slug(params[:id]) || Layer.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def layer_params
    params.require(:layer).permit(:title, :subtitle, :teaser, :text, :credits, :published, :public_submission, :map_id, :color, :background_color, :tooltip_display_mode, :places_sort_order, :basemap_url, :basemap_attribution, :mapcenter_lat, :mapcenter_lon, :zoom, :use_mapcenter_from_parent_map, :image, :backgroundimage, :use_background_from_parent_map, :favicon, :exif_remove, :rasterize_images, :relations_bending, :relations_coloring, :image_alt, :image_licence, :image_source, :image_creator, :image_caption, :ltype, :images_creator, :images_licence, :images_source, images_files: [])
  end

  def validate_images_format
    return unless layer_params && layer_params[:images_files] && layer_params[:images_files].any?

    layer_params[:images_files].each do |file|
      unless ['image/jpeg', 'image/png', 'image/gif'].include?(file.content_type)
        flash[:alert] = 'Invalid file formats found. Only JPEG, PNG and GIF are allowed.'
        return false
      end
    end
    true
  end

  def convert_dms_to_decimal(coord, ref)
    # Extract the parts of the coordinate
    parts = coord.split(', ')
    degrees = parts[0].to_f
    minutes = parts[1].to_f / 100
    seconds = parts[2].to_f

    # Calculate the decimal degrees
    decimal_degrees = degrees + (minutes / 60) + (seconds / 3600)

    # Adjust for the hemisphere
    decimal_degrees *= -1 if %w[S W].include?(ref)
    decimal_degrees
  end

  def create_places_with_exif_data
    created_places = []
    skipped_images = []
    existing_places = @layer.places
    pindex = existing_places.any? ? existing_places.count : 0
    layer_params[:images_files].each_with_index do |file, index|
      # TODO: dupe check?
      place = @layer.places.build
      # TODO: use MiniExiftool instead of MiniMagick
      # exif = MiniExiftool.new(file.tempfile.path)
      i = MiniMagick::Image.open(file.tempfile.path)
      exif = i.exif
      place.title = exif['ImageDescription'] || "##{index + pindex + 1}"
      place.subtitle = file.original_filename
      place.teaser = ''
      place.lat = convert_dms_to_decimal(exif['GPSLatitude'], exif['GPSLatitudeRef'])
      place.lon = convert_dms_to_decimal(exif['GPSLongitude'], exif['GPSLongitudeRef'])
      place.direction = exif['GPSImgDirection'] if exif['GPSImgDirection'].present?
      place.published = true
      place.teaser = "Place tagged by geo-encoded photo <tt>#{file.original_filename}</tt> at <tt>#{exif['GPSLatitude']}</tt> and <tt>#{exif['GPSLongitude']}</tt>."
      place.teaser << " and with direction: #{exif['GPSImgDirection']}." if exif['GPSImgDirection'].present?
      place.teaser << " <br />Geodata converted from DMS to decimal degrees: #{place.lat}/#{place.lon}."
      place.teaser << " <bv />Photo taken at #{exif['DateTimeOriginal']}." if exif['DateTimeOriginal'].present?

      image = place.images.build
      image.title = exif['ImageDescription'] || file.original_filename
      image.creator = exif['Artist'] || layer_params[:images_creator]
      image.licence = exif['Copyright'] || layer_params[:images_licence]
      image.source = layer_params[:images_source]
      image.file = file
      image.preview = true
      if exif['GPSLatitude'].present?
        place.save!
        created_places << place
      else
        skipped_images << file.original_filename
      end
    end
    [created_places, skipped_images]
  end
end
