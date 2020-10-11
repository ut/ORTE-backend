# frozen_string_literal: true

class IconsController < ApplicationController
  before_action :set_icon, only: %i[edit update destroy]

  # GET /icons/1/edit
  def edit; end

  # PATCH/PUT /icons/1
  # PATCH/PUT /icons/1.json
  def update
    @iconset = @icon.iconset
    respond_to do |format|
      if @icon.update(icon_params)
        format.html { redirect_to iconset_url(@iconset), notice: 'Icon was successfully updated.' }
        format.json { render :show, status: :ok, location: @icon }
      else
        format.html { render :edit }
        format.json { render json: @icon.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /icons/1
  # DELETE /icons/1.json
  def destroy
    @iconset = @icon.iconset
    @icon.destroy
    respond_to do |format|
      format.html { redirect_to iconset_url(@iconset), notice: 'Icon was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_icon
    @icon = Icon.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def icon_params
    params.require(:icon).permit(:title, :iconset_id )
  end
end
