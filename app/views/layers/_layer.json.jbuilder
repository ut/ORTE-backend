# frozen_string_literal: true

json.extract! layer, :id, :title, :text, :published, :map_id, :color, :created_at, :updated_at
json.url map_layer_url(layer, format: :json)
json.iconset layer.map.iconset, :title, :icon_anchor, :icon_size, :popup_anchor, :class_name if layer.map.iconset
json.places layer.places do |place|
  json.extract! place, :id, :title, :teaser, :text, :link, :startdate, :enddate, :lat, :lon, :full_address, :location, :address, :zip, :city, :country, :published, :featured, :layer_id, :created_at, :updated_at, :date, :edit_link, :show_link, :imagelink2, :imagelink, :icon_link, :icon_class, :icon_name
  json.annotations place.annotations do |annotation|
    json.extract! annotation, :id, :title, :text, :person_name, :audiolink
  end
end
json.places_with_relations layer.places do |place|
  if place.relations_froms.count > 0
    json.relations place.relations_froms do |relation|
      json.id relation.id
      json.from do
        json.extract! relation.relation_from, :id, :lat, :lon
      end
      json.to do
        json.extract! relation.relation_to, :id, :lat, :lon
      end
    end
  end
end
