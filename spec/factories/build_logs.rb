# frozen_string_literal: true

FactoryBot.define do
  factory :build_log do
    map
    layer
    output { Faker::Hacker.say_something_smart }
    size { Faker::Hacker.adjective }
    version { Faker::Hacker.noun }
    trait :changed do
      output { 'OtherString' }
    end
  end
end
