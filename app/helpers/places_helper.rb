module PlacesHelper

  include Rails.application.routes.url_helpers

   def default_url_options
      { host: Settings.app_host}
    end

  def show_link(title, map_id, layer_id, id)
    " <a href=\"/maps/#{map_id}/layers/#{layer_id}/places/#{id}\">#{title}</a>"
  end

  def edit_link(map_id, layer_id, id)
    " <a href=\"/maps/#{map_id}/layers/#{layer_id}/places/#{id}/edit\" class='edit_link'><i class='fi fi-pencil'></i></a>"
  end

  def add_new_entry_link(place)
    "/maps/#{place.layer.map.id}/layers/#{place.layer.id}/places/new?location=#{@place.location}&address=#{@place.address}&zip=#{@place.zip}&city=#{@place.city}&lat=#{@place.lat}&lon=#{@place.lon}";
  end

  def icon_link(file)
    "<img src=\"#{polymorphic_url(file)}\">"
  end

  def icon_class(klass_name,title)
    "icon_#{klass_name} icon_#{title.parameterize}"
  end

  def icon_name(title)
    "#{title}"
  end

  def image_link(image)
    if image.file.attached?
      polymorphic_url(image.file)
    end
  end

end
