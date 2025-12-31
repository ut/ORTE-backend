# frozen_string_literal: true

FactoryBot.define do
  factory :place do
    uid { Faker::Internet.password(min_length: 3, max_length: 20, special_characters: true) }
    title { Faker::Book.title }
    subtitle { Faker::TvShows::Simpsons.quote }
    teaser { Faker::Lorem.sentence }
    text { Faker::Lorem.paragraph }
    sources { Faker::Artist.name }
    link { Faker::Internet.url }
    startdate { Faker::Time.between(from: DateTime.now - 100.years, to: DateTime.now) }
    enddate { Faker::Time.between(from: DateTime.now - 100.years, to: DateTime.now) }
    lat { Faker::Address.latitude }
    lon { Faker::Address.longitude }
    direction { Faker::Alphanumeric.alphanumeric(number: 3) }
    location { Faker::Games::Pokemon.location }
    address { Faker::Address.street_address }
    zip { Faker::Address.zip }
    city { Faker::Address.city }
    state { Faker::Address.state }
    country { Faker::Address.country }
    published { false }
    imagelink { Faker::Internet.url(path: '/image.png') }
    layer
    trait :published do
      published { true }
    end
    trait :date_and_time do
      startdate_date { Faker::Date.between(from: 100.years.ago, to: 90.years.ago) }
      startdate_time { '11:45' }
      enddate_date { Faker::Date.between(from: 30.years.ago, to: 20.years.ago) }
      enddate_time { '16:45' }
    end
    trait :start_date_and_time do
      startdate_date { Faker::Date.between(from: 100.years.ago, to: Date.today) }
      startdate_time { '11:45' }
    end
    trait :end_date_and_time do
      enddate_date { Faker::Date.between(from: 100.years.ago, to: Date.today) }
      enddate_time { '16:45' }
    end
    trait :invalid do
      title { nil }
    end
    trait :changed do
      title { 'OtherTitle' }
    end
    trait :changed_and_published do
      title { 'OtherTitle' }
      published { true }
    end
    trait :with_tags do
      after(:create) do |place|
        place.tag_list.add('Tag1', 'Tag2', 'Tag3')
        place.save
      end
    end

    trait :with_audio do
      after(:build) do |place|
        place.audio.attach(
          io: File.open(Rails.root.join('spec/support/files/test.mp3')),
          filename: 'test.mp3',
          content_type: 'audio/mpeg'
        )
      end
    end
    trait :with_images do
      published { true }

      transient do
        images_count { 3 }
      end

      after(:build) do |place, evaluator|
        evaluator.images_count.times do |i|
          file_path = Rails.root.join('spec', 'support', 'files', 'test.jpg')
          file = File.open(file_path)
          preview_value = i == 0
          place.images.build(attributes_for(:image, preview: preview_value)).file.attach(
            io: file,
            filename: "sample_image_#{i + 1}.jpg",
            content_type: 'image/jpeg'
          )
          file.close
        end
      end
    end
  end
end
