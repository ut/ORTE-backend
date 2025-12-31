# frozen_string_literal: true

FactoryBot.define do
  factory :import_mapping do
    name { Faker::App.name }
    mapping do
      [
        { csv_column_name: 'id', model_property: 'id', key: true },
        { csv_column_name: 'title', model_property: 'title', key: true },
        { csv_column_name: 'lon', model_property: 'lon', key: false },
        { csv_column_name: 'lat', model_property: 'lat', key: false },
        { csv_column_name: 'teaser', model_property: 'teaser', key: false },
        { csv_column_name: 'text', model_property: 'text', key: false },
        { csv_column_name: 'annotations', model_property: '', key: false },
        { csv_column_name: 'startdate', model_property: 'startdate', key: false },
        { csv_column_name: 'enddate', model_property: 'enddate', key: false },
        { csv_column_name: 'location', model_property: 'location', key: false },
        { csv_column_name: 'address', model_property: 'address', key: false },
        { csv_column_name: 'zip', model_property: 'zip', key: false },
        { csv_column_name: 'city', model_property: 'city', key: false },
        { csv_column_name: 'country', model_property: 'country', key: false }
      ]
    end
    trait :with_parsers do
      mapping do
        [
          { csv_column_name: 'title', model_property: 'title', parsers: '["sanitize", "trim"]', key: true },
          { csv_column_name: 'lon', model_property: 'lon', key: false },
          { csv_column_name: 'lat', model_property: 'lat', key: false }
        ]
      end
    end
    trait :with_layer_id do
      mapping do
        [
          { csv_column_name: 'title', model_property: 'title', key: true },
          { csv_column_name: 'lon', model_property: 'lon', key: false },
          { csv_column_name: 'lat', model_property: 'lat', key: false },
          { csv_column_name: 'level_id', model_property: 'layer_id', key: false }
        ]
      end
    end
  end
end
