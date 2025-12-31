# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    name { Faker::FunnyName.name }
    email { Faker::Internet.email }
    rights { true }
    privacy { true }
    locale { 'en' }
    status { 0 }
    place
  end
end
