# frozen_string_literal: true

module PlacesHelper
  include Rails.application.routes.url_helpers

  def default_url_options
    { host: Rails.application.config_for(:settings).app_host, protocol: Rails.application.config_for(:settings).app_host_protocol }
  end

  def qualifier_for_select
    [['Exact date', 'exact'], ['Approx. date', 'circa']]
  end

  def app_config
    @app_config ||= Rails.application.config_for(:settings)
  end

  def url(map_slug, layer_slug, id)
    "#{app_config.app_host_protocol}://#{app_config.app_host}/maps/#{map_slug}/layers/#{layer_slug}/places/#{id}"
  end

  def show_link(title, map_id, layer_id, id)
    " <a href=\"/maps/#{map_id}/layers/#{layer_id}/places/#{id}\">#{title}</a>"
  end

  def edit_link(map_id, layer_id, id)
    " <a href=\"/maps/#{map_id}/layers/#{layer_id}/places/#{id}/edit\" class='edit_link'><i class='fi fi-pencil'></i></a>"
  end

  def add_new_entry_link(place)
    "/maps/#{place.layer.map.id}/layers/#{place.layer.id}/places/new?location=#{place.location}&address=#{place.address}&zip=#{place.zip}&city=#{place.city}&lat=#{place.lat}&lon=#{place.lon}"
  end

  def icon_link(file)
    "<img src=\"#{polymorphic_url(file)}\">"
  end

  def icon_class(klass_name, title)
    "icon_#{klass_name} icon_#{title.parameterize}"
  end

  def icon_name(title)
    title.to_s
  end

  def image_link(image)
    return unless image.file&.attached?

    begin
      if image.place.layer.rasterize_images && image.itype == 'image'
        polymorphic_url(image.file.variant(resize: '800x800', 'ordered-dither': 'h8x8a').processed)
      else
        polymorphic_url(image.file.variant(resize: '800x800').processed)
      end
    rescue Errno::ENOENT => e
      ''
    rescue ActiveStorage::FileNotFoundError => e
      ''
    end
  end

  def audio_link(audio)
    return '' unless audio.attached?

    audio_tag rails_blob_url(audio), autoplay: false, controls: true
  end
end
