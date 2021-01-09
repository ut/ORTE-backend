# frozen_string_literal: true

json.type "FeatureCollection"
json.title @layer.title
json.text @layer.text
json.id @layer.id

json.features @layer.places do |place|
  next unless place.published
  json.type "Feature"
  json.geometry do
    json.type 'Point'
    json.coordinates [place.lat, place.lon]
  end
  json.properties do
    json.name place.title
    json.teaser place.teaser
    json.text place.text
    json.link place.link
  end
end
