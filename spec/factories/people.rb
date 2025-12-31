# frozen_string_literal: true

FactoryBot.define do
  factory :person do
    name { Faker::FunnyName.name }
    info { Faker::GreekPhilosophers.quote }
    map
    trait :invalid do
      name { nil }
    end
    trait :changed do
      name { 'OtherName' }
    end
  end
end
