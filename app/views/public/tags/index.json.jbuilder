# frozen_string_literal: true

json.array! @tags do |tag|
  json.id tag.id
  json.name tag.name
  json.created_at tag.created_at
  json.updated_at tag.updated_at
  json.taggings_count tag.taggings_count
  json.places(tag.taggings.map(&:taggable).select { |place| @places.include?(place) }) do |place|
    next unless place.published

    # TODO: replace URL with json call for place data
    json.call(place, :id, :uid, :title, :url)
    json.tags place.tags.map(&:name).sort
  end
end
