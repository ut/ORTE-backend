# frozen_string_literal: true

FactoryBot.define do
  factory :layer do
    title { Faker::Book.genre }
    subtitle { Faker::Team.name }
    text { Faker::Hacker.say_something_smart }
    teaser { Faker::Movie.quote }
    credits { Faker::Team.mascot }
    published { false }
    color { Faker::Color.hex_color }
    use_background_from_parent_map { false }
    ltype { 'standard' }
    image_alt { Faker::Quote.famous_last_words }
    image_creator { Faker::Book.author }
    geojson { '{ "type": "FeatureCollection" }' }
    map

    trait :with_ltype_image do
      ltype { 'image' }
    end

    trait :use_background_from_parent_map do
      use_background_from_parent_map { true }
    end

    trait :with_no_color do
      color { false }
    end

    trait :with_wrong_color_format do
      color { 'cc0000' }
    end

    trait :sorted_by_title do
      places_sort_order { 'title' }
    end

    trait :sorted_by_startdate do
      places_sort_order { 'startdate' }
    end

    trait :with_image do
      after(:build) do |layer|
        layer.image.attach(
          io: File.open(Rails.root.join('spec/support/files/test.jpg')),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
    trait :without_image do
      image { [] }
    end
    trait :with_backgroundimage do
      after(:build) do |layer|
        layer.backgroundimage.attach(
          io: File.open(Rails.root.join('spec/support/files/test.jpg')),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
    trait :with_favicon do
      after(:build) do |layer|
        layer.favicon.attach(
          io: File.open(Rails.root.join('spec/support/files/test.jpg')),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
      end
    end

    trait :invalid do
      title { nil }
    end

    trait :changed do
      title { 'OtherTitle' }
    end

    trait :geojson do
      ltype { 'geojson' }
    end
  end
end
