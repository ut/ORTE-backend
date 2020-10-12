# frozen_string_literal: true

json.map do
  next unless @map.published

  json.call(@map, :id, :title, :text, :created_at, :updated_at, :published)
  json.owner @map.group.title
  if @map.iconset
    json.iconset @map.iconset, :title, :icon_anchor, :icon_size, :popup_anchor, :class_name
  end
  json.layer do
    json.array! @map.layers.published do |layer|
      next unless layer.published

      json.call(layer, :id, :title, :text, :created_at, :updated_at, :published)
      json.places do
        json.array! layer.places.published do |place|
          next unless place.published

          json.call(place, :id, :title, :teaser, :link, :imagelink, :imagelink2, :published, :startdate, :enddate, :lat, :lon, :location, :address, :zip, :city, :text, :country, :featured, :layer_id, :icon_link, :icon_class, :icon_name)
        end
      end
    end
  end
end
