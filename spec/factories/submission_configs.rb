# frozen_string_literal: true

FactoryBot.define do
  factory :submission_config do
    title_intro { Faker::Space.planet }
    subtitle_intro { Faker::Space.galaxy }
    intro { Faker::Lorem.sentence }
    title_outro { Faker::Lorem.sentence }
    outro { Faker::Lorem.sentence }
    start_time { Faker::Time.between(from: DateTime.now - 100.years, to: DateTime.now) }
    end_time { Faker::Time.between(from: DateTime.now - 100.years, to: DateTime.now) }
    use_city_only { false }
    trait :invalid do
      title_intro { nil }
    end
    trait :changed do
      title_intro { 'OtherTitle' }
    end
  end
end
