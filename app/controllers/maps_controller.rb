# frozen_string_literal: true

class MapsController < ApplicationController
  before_action :set_map, only: %i[show edit update destroy]

  # GET /maps
  # GET /maps.json
  def index
    @maps = Map.sorted.by_user(current_user)
  end

  # GET /maps/1
  # GET /maps/1.json
  def show
    @maps = Map.sorted.by_user(current_user)
    if @map
      @map_layers = @map.layers
      respond_to do |format|
        format.html { render :show }
        format.json { render :show, filename: "orte-map-#{@map.title.parameterize}-#{I18n.l Date.today}.json" }
      end
    else
      redirect_to maps_path
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
        format.html { redirect_to @map, notice: 'Map was successfully created. Please create at least one layer'  }
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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_map
    @map = Map.by_user(current_user).find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def map_params
    params.require(:map).permit(:title, :subtitle, :text, :published, :script, :group_id, :northeast_corner, :southwest_corner, :iconset_id, :basemap_url, :basemap_attribution)
  end
end
