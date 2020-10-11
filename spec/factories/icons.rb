# frozen_string_literal: true

FactoryBot.define do
  factory :icon do
    title { 'MyString' }
    iconset
    trait :invalid do
      iconset { nil }
    end
    trait :changed do
      title { 'OtherTitle' }
    end
  end
end
