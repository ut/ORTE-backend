# frozen_string_literal: true

json.extract! layer, :id, :title, :subtitle, :text, :credits, :image_link, :published, :map_id, :color, :mapcenter_lat, :mapcenter_lon, :zoom, :relations_bending, :relations_coloring, :image_alt, :image_licence, :image_source, :image_creator, :image_caption, :created_at, :updated_at, :ltype
json.url map_layer_url(layer, format: :json)
json.iconset layer.map.iconset, :title, :icon_anchor, :icon_size, :popup_anchor, :class_name if layer.map.iconset

places_query = places
places_query = places_query.where('title LIKE :query OR teaser LIKE :query OR text LIKE :query', query: "%#{@search}%") if search.present?
places_query = places_query.tagged_with(tag_names) if tag_names.present?

json.places do
  json.array! places_query do |place|
    json.extract! place, :id, :title, :subtitle, :teaser, :text, :sources, :link, :startdate, :enddate, :full_address, :location, :address, :zip, :city, :country, :published, :featured, :layer_id, :layer_type, :layer_title, :layer_color, :color, :created_at, :updated_at, :date, :date_with_qualifier, :url, :edit_link, :show_link, :imagelink2, :imagelink, :icon_link, :icon_class, :icon_name
    json.lat place.public_lat
    json.lon place.public_lon
    if place.layer.map.show_annotations_on_map
      json.annotations place.annotations do |annotation|
        json.extract! annotation, :id, :title, :text, :person_name, :audiolink
      end
    end
  end
end
json.places_with_relations places do |place|
  if place.relations_froms.size.positive?
    json.relations place.relations_froms do |relation|
      json.id relation.id
      json.from do
        json.extract! relation.relation_from, :id, :title, :show_link, :published, :layer_id
        json.lat relation.relation_from.public_lat
        json.lon relation.relation_from.public_lon
      end
      json.to do
        json.extract! relation.relation_to, :id, :title, :show_link, :published, :layer_id
        json.lat relation.relation_to.public_lat
        json.lon relation.relation_to.public_lon
      end
    end
  end
end
