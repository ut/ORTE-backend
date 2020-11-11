# frozen_string_literal: true

class VideosController < ApplicationController
  before_action :set_video, only: %i[show edit update destroy]

  # GET /videos
  # GET /videos.json
  def index
    @place = Place.where(id: params[:place_id]).first
    redirect_to root_url, notice: 'No place defined for showing this video' if !@place || @place.layer.map.group != current_user.group
    @videos = Video.where(place_id: @place_id)
  end

  def transition
    @places = Place.all
    # This joins statement returns all Places with an attachement,  "Place.with_attached_videos" just counts all places!
    @places_videos = Place.joins(:videos_attachments)
    @videos_file = Video.joins(:file_attachment)
  end

  # GET /videos/1
  # GET /videos/1.json
  def show
    redirect_to root_url, notice: "You are not allowed for viewing this video #{current_user.group.title}" if @video.place.layer.map.group != current_user.group && current_user.group.title != 'Admins'
  end

  # GET /videos/new
  def new
    @video = Video.new
    @map = Map.by_user(current_user).find(params[:map_id])
    @layer = Layer.find(params[:layer_id])
    @place = Place.find(params[:place_id])
    redirect_to root_url, notice: 'No place defined for adding an video' unless @place || (@place && @place.layer.map.group == current_user.group)
  end

  # GET /videos/1/edit
  def edit
    @place = @video.place
    redirect_to root_url, notice: 'No valid place defined for editing an mage' unless @place || (@place && @place.layer.map.group == current_user.group)
  end

  # POST /videos
  # POST /videos.json
  def create
    @video = Video.new(video_params)
    @map = Map.by_user(current_user).find(params[:map_id])
    @layer = Layer.find(params[:layer_id])
    @place = Place.find(params[:place_id])
    respond_to do |format|
      if @video.save
        format.html { redirect_to edit_map_layer_place_path(@video.place.layer.map, @video.place.layer, @video.place), notice: 'Video was successfully created.' }
        format.json { render :show, status: :created, location: @video }
      else
        format.html { render :new }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /videos/1
  # PATCH/PUT /videos/1.json
  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to edit_map_layer_place_path(@video.place.layer.map, @video.place.layer, @video.place), notice: 'Video was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video.destroy
    respond_to do |format|
      format.html { redirect_to edit_map_layer_place_path(@video.place.layer.map, @video.place.layer, @video.place), notice: 'Video was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_video
    @map = Map.by_user(current_user).where(id: params[:map_id]).first
    @layer = Layer.find(params[:layer_id])
    @place = Place.find(params[:place_id])
    @video = Video.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def video_params
    params.require(:video).permit(:title, :licence, :source, :creator, :place_id, :alt, :caption, :sorting, :preview, :file)
  end
end
