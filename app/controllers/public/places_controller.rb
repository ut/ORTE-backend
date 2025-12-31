# frozen_string_literal: true

class Public::PlacesController < ActionController::Base
  before_action :cors_set_access_control_headers

  protect_from_forgery with: :exception

  # For all responses in this controller, return the CORS access control headers.

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def show
    @place = Place.published.find_by_id(params[:id])

    respond_to do |format|
      if @place.present?
        format.json { render :show }
      else
        format.json { render json: { error: 'Place not accessible (You\'ll have to publish the place first)' }, status: :forbidden }
      end
    end
  end
end
