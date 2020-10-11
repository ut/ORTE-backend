# frozen_string_literal: true

json.extract! map, :id, :title, :text, :published, :group_id, :created_at, :updated_at
json.url map_url(map, format: :json)
json.layers map.layers do |layer|
  json.extract! layer, :id, :title, :text, :published, :map_id, :color, :created_at, :updated_at
  if layer.map.iconset
    json.iconset layer.map.iconset, :title, :icon_anchor, :icon_size, :popup_anchor, :class_name
  end
  json.places layer.places do |place|
    json.extract! place, :id, :title, :teaser, :text, :link, :startdate, :enddate, :lat, :lon, :full_address, :location, :address, :zip, :city, :country, :published, :featured, :layer_id, :created_at, :updated_at, :date, :edit_link, :show_link, :imagelink2, :imagelink, :icon_link, :icon_class, :icon_name
  end
end
