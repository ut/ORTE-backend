# frozen_string_literal: true

FactoryBot.define do
  factory :place do
    title { 'MyTitle' }
    teaser { 'MyText' }
    text { 'MyText' }
    link { 'http://domain.com' }
    startdate { '2018-04-27 19:48:51' }
    enddate { '2018-04-27 19:48:51' }
    lat { 'Lat' }
    lon { 'Lon' }
    location { 'Location' }
    address { 'Address' }
    zip { 'Zip' }
    city { 'City' }
    country { 'Country' }
    published { false }
    layer
    trait :published do
      published { true }
    end
    trait :date_and_time do
      startdate_date { '2018-04-30' }
      startdate_time { '11:45' }
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
    trait :with_audio do
      audio { [fixture_file_upload(Rails.root.join('spec', 'support', 'files', 'test.mp3'), 'audio/mpeg')] }
    end
    trait :with_images do
      # deprecated
      images { [fixture_file_upload(Rails.root.join('spec', 'support', 'files', 'test.jpg'), 'image/jpeg')] }
    end
  end
end
