# frozen_string_literal: true

FactoryBot.define do
  factory :video do
    title { Faker::GreekPhilosophers.name }
    licence { Faker::Hipster.word }
    source { Faker::Book.publisher }
    creator { Faker::Book.author }
    place
    alt { Faker::Commerce.material }
    caption { Faker::Commerce.department }
    sorting { Faker::Number.between(from: 1, to: 10) }
    preview { false }
    trait :with_file do
      after(:build) do |video|
        video.file.attach(
          io: File.open(Rails.root.join('spec/support/files/test.mp4')),
          filename: 'test.txt',
          content_type: 'video/mp4'
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
    trait :invalid do
      title { nil }
      place { nil }
      file { [] }
    end
    trait :changed do
      title { 'OtherTitle' }
    end
  end
end
