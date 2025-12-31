# frozen_string_literal: true

json.extract! place.layer, :id, :title, :text, :published, :map_id, :color, :created_at, :updated_at
json.url map_layer_url(place.layer, format: :json)
json.iconset place.layer.map.iconset, :title, :icon_anchor, :icon_size, :popup_anchor, :class_name if place.layer.map.iconset

json.places do
  json[] do
    json.extract! place, :id, :title, :teaser, :text, :sources, :link, :date, :date_with_qualifier, :startdate, :enddate, :full_address, :location, :address, :zip, :city, :country, :published, :featured, :layer_id, :created_at, :updated_at, :date, :edit_link, :show_link, :imagelink2, :imagelink, :icon_link, :icon_class, :icon_name
    json.lat place.public_lat
    json.lon place.public_lon
    json.images(place.images).order('sorting ASC') do |image|
      json.image_url rails_blob_path(image) if image.file&.attached?
    end
  end
end
