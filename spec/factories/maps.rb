# frozen_string_literal: true

FactoryBot.define do
  factory :map do
    title { Faker::Book.title }
    subtitle { Faker::Lorem.sentence }
    text {  Faker::Lorem.paragraph }
    credits { Faker::Book.author }
    basemap_url { Faker::Internet.url(path: '/map.png') }
    basemap_attribution { Faker::Lorem.sentence }
    background_color { Faker::Color.hex_color }
    mapcenter_lat { Faker::Address.latitude }
    mapcenter_lon { Faker::Address.longitude }
    group
    trait :invalid do
      title { nil }
    end
    trait :update do
      title { 'MyNewString' }
    end
  end
end
