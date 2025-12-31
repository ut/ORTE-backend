# frozen_string_literal: true

require 'csv'

class MapsController < ApplicationController
  include ImportContextHelper

  before_action :set_map, only: %i[show edit update destroy import import_preview importing]

  before_action :redirect_to_friendly_id, only: %i[show]

  # GET /maps
  # GET /maps.json
  def index
    @maps = Map.sorted.by_user(current_user)
  end

  # GET /maps/1
  # GET /maps/1.json
  def show
    @maps = Map.sorted.by_user(current_user)

    if @map&.layers
      @map_layers = @map.layers.includes(:image_attachment, places: [:icon, :annotations, :tags, { images: { file_attachment: :blob }, audio_attachment: :blob, relations_froms: %i[relation_from relation_to] }])
      # @map_layers = @map.layers
      @places = Place.where(id: @map_layers.flat_map(&:places).map(&:id))
      @tags = @places.all_tags
      @tags_count = @tags.count
      @tags_max_count = @tags.map(&:taggings_count).max || 1
      @tags_count_threshold = (@tags_max_count * 0.1).ceil

      if params[:search] && !params[:search].empty?
        @search = params[:search]
        @places = @places.where('places.title LIKE :query OR places.teaser LIKE :query OR places.text LIKE :query', query: "%#{@search}%")
      end
      if params[:filter].present?
        @tag_names = params[:filter].split(',')
        @places = @places.tagged_with(@tag_names)
      end

      if @map.enable_time_slider
        @places_with_dates = @places.reject { |place| place.startdate.nil? && place.enddate.nil? }
        # timeline calculation, for now on a yearly basis
        @minyear = @places.reject { |place| place.startdate.nil? }.min_by { |place| place.startdate.year }&.startdate&.year || Date.today.year
        @maxyear = @places.reject { |place| place.enddate.nil? }.max_by { |place| place.enddate.year }&.enddate&.year || Date.today.year

        # make a hash, where the key is a single year and it contains all places that are active in that year
        @places_by_year = {}
        @places_with_dates.each do |place|
          startyear = place.startdate.nil? ? @minyear : place.startdate.year
          endyear = place.enddate.nil? ? startyear : place.enddate.year
          (startyear..endyear).each do |year|
            @places_by_year[year.to_i] ||= []
            @places_by_year[year.to_i] << place
          end
        end
        @timespan = @maxyear - @minyear
      end
      respond_to do |format|
        format.html { render :show }
        format.json { render :show, filename: "orte-map-#{@map.title.parameterize}-#{I18n.l Date.today}.json" }
      end
    else
      redirect_to maps_path, notice: 'Sorry, this map could not be found.'
    end
  end

  # GET /maps/new
  def new
    @map = Map.new
    @groups = Group.by_user(current_user)
  end

  # GET /maps/1/edit
  def edit
    @map.northeast_corner = params[:northeast] if params[:northeast]
    @map.southwest_corner = params[:southwest] if params[:southwest]
  end

  # POST /maps
  # POST /maps.json
  def create
    @map = Map.new(map_params)

    respond_to do |format|
      if @map.save
        format.html { redirect_to @map, notice: 'Map was successfully created. Please create at least one layer' }
        format.json { render :show, status: :created, location: @map }
      else
        format.html { render :new }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /maps/1
  # PATCH/PUT /maps/1.json
  def update
    respond_to do |format|
      if @map.update(map_params)
        format.html { redirect_to @map, notice: 'Map was successfully updated.' }
        format.json { render :show, status: :ok, location: @map }
      else
        format.html { render :edit }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maps/1
  # DELETE /maps/1.json
  def destroy
    @map.destroy
    respond_to do |format|
      format.html { redirect_to maps_url, notice: 'Map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def import; end

  def import_preview
    if params[:import].blank? || params[:import][:file].blank?
      flash[:alert] = 'Please select a file before proceeding.'
      redirect_to import_map_path(@map) and return
    end
    file = params[:import][:file]
    return unless file

    ImportContextHelper.write_tempfile_path(file)
    column_separator = params[:import][:column_separator] || ','
    @col_sep = case column_separator
               when 'Comma'
                 ','
               when 'Semicolon'
                 ';'
               when 'Tab'
                 "\t"
               else
                 ','
               end
    @quote_char = params[:import][:quote_char] || '"'
    begin
      @headers = CSV.read(file.path, headers: true, col_sep: @col_sep, quote_char: @quote_char).headers
      importer = Imports::MappingCsvImporter.new(file, nil, @map.id, ImportMapping.new, col_sep: @col_sep, quote_char: @quote_char)
      importer.import
      @missing_fields = importer.missing_fields
      flash[:notice] = 'CSV read successfully!'
      redirect_to new_import_mapping_path(headers: @headers, missing_fields: @missing_fields, file_name: file.original_filename, col_sep: @col_sep, quote_char: @quote_char, map_id: @map.id)
    rescue CSV::MalformedCSVError => e
      ImportContextHelper.delete_tempfile_and_cache_path(file.original_filename)
      flash[:error] = "Maybe the file has a different column separator? Or it does not contain CSV? (Malformed CSV: #{e.message})"
      render :import
    end
  end

  def importing
    file_name = params[:file_name]
    import_mapping = ImportMapping.find(params[:import_mapping_id])
    importing_rows_data = ImportContextHelper.read_importing_rows(file_name)

    if importing_rows_data
      importing_rows = importing_rows_data.map do |place_data|
        Place.new(place_data.attributes)
      end
    end

    importing_duplicate_rows_data = ImportContextHelper.read_importing_duplicate_rows(file_name)
    importing_duplicate_rows_data&.each do |place|
      existing_place = Place.find_by(duplicate_key_values(import_mapping, place))
      existing_place&.update(place.attributes.except('id', 'created_at', 'updated_at'))
    end
    importing_rows&.each(&:save!)
    ImportContextHelper.delete_tempfile_and_cache_path(file_name)
    if (importing_rows && !importing_rows.empty?) || (importing_duplicate_rows_data && !importing_duplicate_rows_data.empty?)
      redirect_to map_path(@map), notice: "CSV import to #{@map.title} completed successfully! (#{importing_rows&.count || 0} places have been created and #{importing_duplicate_rows_data&.count || 0} places have been updated.)"
    else
      redirect_to import_map_path(@map), notice: 'No data provided to import!'
    end
  end

  private

  def redirect_to_friendly_id
    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the post_path, and we should do
    # a 301 redirect that uses the current friendly id.
    redirect_to @map, status: :moved_permanently if @map && request.path != map_path(@map) && request.format == 'html'
  end

  def set_map
    # flexible query: Find slugged resource, if not, find a non-slugged resoure. All that to avoid an exception if a resource is unknown or not accessible (which would happen with friendly.find)
    @map = Map.by_user(current_user).find_by_slug(params[:id]) || Map.by_user(current_user).find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def map_params
    params.require(:map).permit(:title, :subtitle, :text, :credits, :published, :script, :image, :group_id, :mapcenter_lat, :mapcenter_lon, :zoom, :northeast_corner, :southwest_corner, :iconset_id, :basemap_url, :basemap_attribution, :background_color, :popup_display_mode, :marker_display_mode, :show_annotations_on_map, :preview_url, :enable_privacy_features, :enable_map_to_go, :enable_historical_maps, :enable_time_slider)
  end
end
