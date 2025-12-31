# frozen_string_literal: true

FactoryBot.define do
  factory :annotation do
    title { Faker::Mountain.name }
    text { Faker::Commerce.department }
    published { true }
    sorting { Faker::Number.within(range: 1..20) }
    source { Faker::Artist.name }
    place
    person
    trait :with_audio do
      after(:build) do |annotation|
        annotation.audio.attach(
          io: File.open(Rails.root.join('spec/support/files/test.mp3')),
          filename: 'test.mp3',
          content_type: 'audio/mpeg'
        )
      end
    end
    trait :invalid do
      text { nil }
    end
    trait :changed do
      text { 'OtherText' }
    end
  end
end
