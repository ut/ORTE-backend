# frozen_string_literal: true

FactoryBot.define do
  factory :iconset do
    title { Faker::Artist.name }
    text {  Faker::Lorem.sentence }
    icon_anchor { '[100,100]' }
    icon_size { '[50,50]' }
    popup_anchor { '[0,70]' }
    class_name { Faker::Internet.slug }
    trait :invalid do
      title { nil }
    end
    trait :changed do
      title { 'OtherTitle' }
    end
  end
end
