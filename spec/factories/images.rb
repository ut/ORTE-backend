# frozen_string_literal: true

FactoryBot.define do
  factory :image do
    title { Faker::Commerce.product_name }
    licence { Faker::FunnyName.two_word_name }
    source {  Faker::Lorem.word }
    creator { Faker::FunnyName.name }
    place
    alt { Faker::Lorem.sentence }
    caption { Faker::Hipster.sentence }
    sorting { Faker::Number.between(from: 1, to: 10) }
    preview { false }
    itype { 'image' }
    trait :with_file do
      after(:build) do |image|
        image.file.attach(
          io: File.open(Rails.root.join('spec/support/files/test.jpg')),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
    trait :with_geocoded_file do
      after(:build) do |image|
        image.file.attach(
          io: File.open(Rails.root.join('spec/support/files/test-with-exif-data.jpg')),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
    trait :without_file do
      file { [] }
    end
    trait :with_wrong_fileformat do
      after(:build) do |post|
        post.file.attach(
          io: File.open(Rails.root.join('spec/support/files/test.txt')),
          filename: 'test.txt',
          content_type: 'image/jpeg'
        )
      end
    end
    trait :notitle do
      title { nil }
    end
    trait :nofile do
      file { [] }
    end
    trait :invalid do
      title { nil }
      place { nil }
      file { [] }
    end
    trait :changed do
      title { 'OtherTitle' }
    end
    trait :preview do
      preview { true }
    end
  end
end
