# frozen_string_literal: true

json.layer do
  next unless @layer.published
  json.call(@layer, :id, :title, :text, :created_at, :updated_at, :published)
  json.places do
    json.array! @layer.places.published do |place|
      next unless place.published
      json.call(place, :id, :title, :teaser, :link, :imagelink, :imagelink2, :audiolink, :published, :startdate, :enddate, :lat, :lon, :location, :address, :zip, :city, :text, :country, :featured, :layer_id, :icon_link, :icon_class, :icon_name)

      json.images do
        json.array! place.images do |image|
          json.call(image, :id, :title, :source, :creator, :alt, :sorting, :image_linktag, :image_url)
        end
      end
    end
  end
end
