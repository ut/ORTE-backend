# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  protect_from_forgery with: :exception

  rescue_from ImportCacheExpiredException, with: :handle_import_cache_expired

  def report_csp
    # do nothing right now...
  end

  def default_checkbox?(param)
    %w[on true].include?(param)
  end

  private

  def handle_import_cache_expired
    alert = 'Import-Cache has expired, please try again.'
    if params[:layer_id] && params[:map_id]
      redirect_to import_map_layer_path(map_id: params[:map_id], id: params[:layer_id]), alert: alert
    elsif params[:map_id]
      redirect_to import_map_path(params[:map_id]), alert: alert
    else
      redirect_to root_path, alert: alert
    end
  end
end
