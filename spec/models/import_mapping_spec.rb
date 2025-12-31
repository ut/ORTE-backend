# frozen_string_literal: true

# spec/models/import_mapping_spec.rb
require 'rails_helper'

RSpec.describe ImportMapping, type: :model do
  describe 'validations' do
    let(:valid_mapping) do
      [
        { 'csv_column_name' => 'title', 'model_property' => 'title' },
        { 'csv_column_name' => 'lat', 'model_property' => 'lat' },
        { 'csv_column_name' => 'lon', 'model_property' => 'lon' }
      ]
    end

    it 'is valid if all required properties are present' do
      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: valid_mapping
      )
      expect(import_mapping).to be_valid
    end

    it 'is valid if mapping contains duplicate empty strings as model properties' do
      mapping_with_empty_values = [
        { 'csv_column_name' => 'title', 'model_property' => 'title' },
        { 'csv_column_name' => 'lat', 'model_property' => 'lat' },
        { 'csv_column_name' => 'lon', 'model_property' => 'lon' },
        { 'csv_column_name' => 'something', 'model_property' => '' },
        { 'csv_column_name' => 'something else', 'model_property' => '' }
      ]

      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: mapping_with_empty_values
      )

      expect(import_mapping).to be_valid
    end

    it 'is invalid if mapping contains duplicate model properties' do
      invalid_mapping = [
        { 'csv_column_name' => 'title', 'model_property' => 'title' },
        { 'csv_column_name' => 'lat', 'model_property' => 'lat' },
        { 'csv_column_name' => 'lon', 'model_property' => 'lon' },
        { 'csv_column_name' => 'duplicate_lat', 'model_property' => 'lat' }
      ]

      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: invalid_mapping
      )

      expect(import_mapping).not_to be_valid
      expect(import_mapping.errors[:mapping]).to include('contains duplicate model properties: lat')
    end

    it 'is invalid without a name' do
      import_mapping = ImportMapping.new(name: nil, mapping: valid_mapping)
      expect(import_mapping).not_to be_valid
      expect(import_mapping.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a duplicate name' do
      ImportMapping.create!(name: 'Duplicate Name', mapping: valid_mapping)
      duplicate_mapping = ImportMapping.new(
        name: 'Duplicate Name',
        mapping: valid_mapping
      )
      expect(duplicate_mapping).not_to be_valid
      expect(duplicate_mapping.errors[:name]).to include('has already been taken')
    end

    it 'is invalid if required properties are missing' do
      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: [
          { 'csv_column_name' => 'title', 'model_property' => 'title' }
        ]
      )
      expect(import_mapping).not_to be_valid
      expect(import_mapping.errors[:mapping]).to include('is missing required properties: lat, lon')
    end

    it 'is invalid if mapping is empty' do
      import_mapping = ImportMapping.new(name: 'Test Mapping', mapping: [])
      expect(import_mapping).not_to be_valid
      expect(import_mapping.errors[:mapping]).to include('is missing required properties: title, lat, lon')
    end

    it 'is invalid if it includes non-existing parser names' do
      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: [
          { 'csv_column_name' => 'title', 'model_property' => 'title', 'parsers' => '["non_existing_parser"]' },
          { 'csv_column_name' => 'lat', 'model_property' => 'lat', 'parsers' => '[]' },
          { 'csv_column_name' => 'lon', 'model_property' => 'lon', 'parsers' => '[]' }
        ]
      )
      expect(import_mapping).not_to be_valid
      expect(import_mapping.errors[:mapping]).to include('contains undefined parsers: non_existing_parser')
    end

    it 'is invalid if parser names are passed in wrong format' do
      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: [
          { 'csv_column_name' => 'title', 'model_property' => 'title', 'parsers' => '[trim]' },
          { 'csv_column_name' => 'lat', 'model_property' => 'lat', 'parsers' => '{trim}' },
          { 'csv_column_name' => 'lon', 'model_property' => 'lon', 'parsers' => '"trim"' }
        ]
      )
      expect(import_mapping).not_to be_valid
      expect(import_mapping.errors[:mapping]).to include('contains invalid parser format: [trim]')
      expect(import_mapping.errors[:mapping]).to include('contains invalid parser format: {trim}')
      expect(import_mapping.errors[:mapping]).to include('contains invalid parser format: trim')
    end

    it 'is valid if parsers is a valid JSON array of strings with existing parser_names' do
      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: [
          { 'csv_column_name' => 'title', 'model_property' => 'title', 'parsers' => '["trim"]' },
          { 'csv_column_name' => 'lat', 'model_property' => 'lat', 'parsers' => '["strip_html_tags"]' },
          { 'csv_column_name' => 'lon', 'model_property' => 'lon', 'parsers' => '["remove_leading_hash"]' }
        ]
      )
      expect(import_mapping).to be_valid
    end

    it 'is valid if parsers is an empty JSON array' do
      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: [
          { 'csv_column_name' => 'title', 'model_property' => 'title', 'parsers' => '[]' },
          { 'csv_column_name' => 'lat', 'model_property' => 'lat', 'parsers' => '[]' },
          { 'csv_column_name' => 'lon', 'model_property' => 'lon', 'parsers' => '[]' }
        ]
      )
      expect(import_mapping).to be_valid
    end

    it 'is invalid if parsers is not a JSON array' do
      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: [
          { 'csv_column_name' => 'title', 'model_property' => 'title', 'parsers' => 'trim' }
        ]
      )
      expect(import_mapping).not_to be_valid
      expect(import_mapping.errors[:mapping]).to include('contains invalid parser format: trim')
    end

    it 'is invalid if parsers contains non-string elements' do
      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: [
          { 'csv_column_name' => 'title', 'model_property' => 'title', 'parsers' => '[1, "trim"]' }
        ]
      )
      expect(import_mapping).not_to be_valid
      expect(import_mapping.errors[:mapping]).to include('contains invalid parser format: [1, "trim"]')
    end

    it 'is invalid if parsers contains undefined parser names' do
      import_mapping = ImportMapping.new(
        name: 'Test Mapping',
        mapping: [
          { 'csv_column_name' => 'title', 'model_property' => 'title', 'parsers' => '["non_existing_parser"]' }
        ]
      )
      expect(import_mapping).not_to be_valid
      expect(import_mapping.errors[:mapping]).to include('contains undefined parsers: non_existing_parser')
    end
  end

  describe '#unprocessable_fields' do
    let(:import_mapping) do
      ImportMapping.new(
        mapping: [
          { 'csv_column_name' => 'title', 'model_property' => 'title' },
          { 'csv_column_name' => 'lat', 'model_property' => 'lat' },
          { 'csv_column_name' => 'lon', 'model_property' => 'lon' }
        ]
      )
    end

    it 'returns headers that are not mapped' do
      header_row = %w[title lat lon extra_column]
      expect(import_mapping.unprocessable_fields(header_row)).to eq(['extra_column'])
    end

    it 'returns an empty array if all headers are mapped' do
      header_row = %w[title lat lon]
      expect(import_mapping.unprocessable_fields(header_row)).to eq([])
    end

    it 'returns an empty array if header row is empty' do
      header_row = []
      expect(import_mapping.unprocessable_fields(header_row)).to eq([])
    end
  end

  describe '.from_header' do
    it 'creates an ImportMapping with matching headers' do
      header_row = %w[title lat extra_column]
      import_mapping = ImportMapping.from_header(header_row)

      expect(import_mapping.mapping).to eq([
                                             { 'csv_column_name' => 'title', 'model_property' => 'title', 'parsers' => [], 'key' => false },
                                             { 'csv_column_name' => 'lat', 'model_property' => 'lat', 'parsers' => [], 'key' => false }
                                           ])
    end

    it 'returns an empty mapping if no headers match' do
      header_row = ['non_matching_column']
      import_mapping = ImportMapping.from_header(header_row)

      expect(import_mapping.mapping).to eq([])
    end

    it 'handles an empty header row' do
      header_row = []
      import_mapping = ImportMapping.from_header(header_row)

      expect(import_mapping.mapping).to eq([])
    end

    it 'ignores duplicate headers in the input' do
      header_row = %w[title title lat]
      import_mapping = ImportMapping.from_header(header_row)

      expect(import_mapping.mapping).to eq([
                                             { 'csv_column_name' => 'title', 'model_property' => 'title', 'parsers' => [], 'key' => false },
                                             { 'csv_column_name' => 'lat', 'model_property' => 'lat', 'parsers' => [], 'key' => false }
                                           ])
    end
  end

  it 'ensures the id mapping has key set to true' do
    import_mapping = ImportMapping.new(
      name: 'Test Mapping',
      mapping: [
        { 'csv_column_name' => 'id', 'model_property' => 'id', 'parsers' => '[]', 'key' => false },
        { 'csv_column_name' => 'title', 'model_property' => 'title', 'parsers' => '[]', 'key' => false },
        { 'csv_column_name' => 'lat', 'model_property' => 'lat', 'parsers' => [], 'key' => false },
        { 'csv_column_name' => 'lon', 'model_property' => 'lon', 'parsers' => [], 'key' => false }

      ]
    )
    import_mapping.save

    expect(import_mapping.mapping.find { |m| m['model_property'] == 'id' }['key']).to eq(true)
  end
end
