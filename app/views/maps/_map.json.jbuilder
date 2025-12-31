# frozen_string_literal: true

json.extract! map, :id, :title, :subtitle, :text, :credits, :image_link, :published, :group_id, :created_at, :updated_at, :show_annotations_on_map
json.url map_url(map, format: :json)

json.layers @map_layers do |layer|
  json.extract! layer, :id, :title, :subtitle, :text, :credits, :image_link, :published, :map_id, :color, :relations_bending, :relations_coloring, :image_alt, :image_licence, :image_source, :image_creator, :image_caption, :created_at, :updated_at, :ltype, :geojson
  json.iconset layer.map.iconset, :title, :icon_anchor, :icon_size, :popup_anchor, :class_name if layer.map.iconset

  # places_query = @places
  places_query = layer.places

  places_query = places_query.where('title LIKE :query OR teaser LIKE :query OR text LIKE :query', query: "%#{@search}%") if @search.present?

  places_query = places_query.tagged_with(@tag_names) if @tag_names.present?

  json.places do
    json.array! places_query do |place|
      json.call(place, :id, :title, :subtitle, :teaser, :text, :sources, :link, :startdate, :enddate, :date_with_qualifier, :full_address, :location, :address, :zip, :city, :country, :published, :featured, :shy, :layer_id, :layer_title, :layer_color, :layer_type, :created_at, :updated_at, :date, :url, :edit_link, :show_link, :imagelink2, :imagelink, :icon_link, :icon_class, :icon_name, :tags)
      json.lat place.public_lat
      json.lon place.public_lon
      if map.show_annotations_on_map
        json.annotations place.annotations do |annotation|
          json.extract! annotation, :id, :title, :text, :person_name, :audiolink
        end
      end
    end
  end
  json.places_with_relations layer.places do |place|
    if place.relations_froms.size.positive?
      json.relations place.relations_froms do |relation|
        json.id relation.id
        json.from do
          json.extract! relation.relation_from, :id
          json.lat relation.relation_from.public_lat
          json.lon relation.relation_from.public_lon
        end
        json.to do
          json.extract! relation.relation_to, :id
          json.lat relation.relation_to.public_lat
          json.lon relation.relation_to.public_lon
        end
      end
    end
  end
end
json.places_by_year @places_by_year do |year, places|
  json.set! year, places
end
