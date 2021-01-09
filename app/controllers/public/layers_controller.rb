# frozen_string_literal: true

class Public::LayersController < ActionController::Base
  before_action :cors_set_access_control_headers

  # For all responses in this controller, return the CORS access control headers.

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end


  # GET /maps/1/layers/1.json
  def show
    @layer = Layer.published.find_by_id(params[:id])

    respond_to do |format|
      if @layer.present?
        format.json { render :show }
        format.geojson { render :show, mime_type: Mime::Type.lookup("application/geo+json")}
      else
        # format.json { head :no_content }
        format.json { render json: { error: 'Layer not accessible' }, status: :forbidden }
        format.geojson { render json: { error: 'Layer not accessible' }, status: :forbidden }
      end
    end
  end
end
