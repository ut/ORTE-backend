# frozen_string_literal: true

json.layer do
  next unless layer.published

  json.call(layer, :id, :title, :subtitle, :text, :teaser, :credits, :image_link, :image_filename, :backgroundimage_link, :backgroundimage_filename, :favicon_link, :favicon_filename, :color, :style, :basemap_url, :basemap_attribution, :background_color, :tooltip_display_mode, :mapcenter_lat, :mapcenter_lon, :zoom, :relations_bending, :relations_coloring, :created_at, :updated_at, :published)
  json.places do
    json.array! places do |place|
      next unless place.published

      json.call(place, :id, :uid, :title, :subtitle, :teaser, :text, :sources, :link, :imagelink, :imagelink2, :audiolink, :published, :date_with_qualifier, :startdate, :enddate, :startdate_qualifier, :enddate_qualifier, :location, :address, :zip, :city, :text, :country, :featured, :layer_id, :icon_link, :icon_class, :icon_name)
      json.lat place.public_lat
      json.lon place.public_lon
      json.tags place.tags.map(&:name).sort
      json.annotations place.annotations do |annotation|
        json.extract! annotation, :id, :title, :text, :person_name, :audiolink
      end
      json.images do
        json.array!(place.images.sort_by { |image| [image.sorting ? 0 : 1, image.sorting] }) do |image|
          json.call(image, :id, :title, :source, :creator, :alt, :sorting, :image_linktag, :image_url, :image_path, :image_filename, :image_on_disk)
        end
      end
    end
  end
  json.places_with_relations places do |place|
    next unless place.published

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
end
