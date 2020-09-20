# frozen_string_literal: true

FactoryBot.define do
  factory :image do
    title { 'Title' }
    licence { 'Licence' }
    source { 'Source' }
    creator { 'Creator' }
    place
    alt { 'Alt' }
    caption { 'Caption' }
    sorting { 2 }
    preview { false }
    trait :with_file do
      file { [fixture_file_upload(Rails.root.join('public', 'apple-touch-icon.png'), 'image/png')] }
    end
    trait :without_file do
      file { [] }
    end
    trait :with_wrong_fileformat do
      file { [fixture_file_upload(Rails.root.join('spec', 'support', 'files', 'test.txt'), '')] }
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
