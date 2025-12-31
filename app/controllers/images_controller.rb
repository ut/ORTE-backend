# frozen_string_literal: true

class ImagesController < ApplicationController
  before_action :set_image, only: %i[show edit update destroy]

  # GET /images
  # GET /images.json
  def index
    @place = Place.where(id: params[:place_id]).first
    redirect_to root_url, notice: 'No place defined for showing this image' if !@place || @place.layer.map.group != current_user.group
    @images = Image.where(place_id: @place_id)
  end

  # GET /images/1
  # GET /images/1.json
  def show
    redirect_to root_url, notice: "You are not allowed for viewing this image #{current_user.group.title}" if @image.place.layer.map.group != current_user.group && current_user.group.title != 'Admins'
  end

  # GET /images/new
  def new
    @image = Image.new
    @map = Map.by_user(current_user).friendly.find(params[:map_id])
    @layer = Layer.friendly.find(params[:layer_id])
    @place = Place.find(params[:place_id])
    redirect_to root_url, notice: 'No place defined for adding an image' unless @place || (@place && @place.layer.map.group == current_user.group)
  end

  # GET /images/1/edit
  def edit
    @place = @image.place
    redirect_to root_url, notice: 'No valid place defined for editing an mage' unless @place || (@place && @place.layer.map.group == current_user.group)
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(image_params)
    @map = Map.by_user(current_user).friendly.find(params[:map_id])
    @layer = Layer.friendly.find(params[:layer_id])
    @place = Place.find(params[:place_id])
    respond_to do |format|
      if @image.save
        format.html { redirect_to edit_map_layer_place_path(@image.place.layer.map, @image.place.layer, @image.place), notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    params[:image][:preview] = default_checkbox?(params[:image][:preview])
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to edit_map_layer_place_path(@image.place.layer.map, @image.place.layer, @image.place), notice: 'Image was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to edit_map_layer_place_path(@image.place.layer.map, @image.place.layer, @image.place), notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @map = Map.by_user(current_user).friendly.find(params[:map_id])
    @layer = Layer.friendly.find(params[:layer_id])
    @place = Place.find(params[:place_id])
    @image = Image.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def image_params
    params.require(:image).permit(:title, :licence, :source, :creator, :place_id, :alt, :caption, :sorting, :preview, :file, :itype)
  end
end
