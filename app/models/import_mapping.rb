# frozen_string_literal: true

class ImportMapping < ApplicationRecord
  before_save :ensure_id_is_key
  validate :validate_required_model_properties
  validate :validate_unique_model_properties
  validate :validate_parsers
  validates :name, presence: true
  validates :name, uniqueness: true

  # overwrite the getter to ensure that the mapping is always parsed as JSON
  # (MariaDB stores JSON as a string)
  def mapping
    return [] if super.blank?

    if super.is_a?(String)
      begin
        JSON.parse(super)
      rescue JSON::ParserError
        []
      end
    else
      super
    end
  end

  # overwrite the setter to ensure that the mapping is always stored as JSON
  def mapping=(value)
    super(value.is_a?(Array) || value.is_a?(Hash) ? value.to_json : value)
  end

  def self.from_header(header_row)
    matching_headers = header_row.uniq.filter do |column_name|
      Place.column_names.map(&:downcase).include?(column_name.downcase)
    end.map do |column_name|
      {
        'csv_column_name' => column_name,
        'model_property' => Place.column_names.find { |col| col.casecmp?(column_name) },
        'parsers' => [],
        'key' => false
      }
    end
    ImportMapping.new(mapping: matching_headers)
  end

  def parse(value, parser_names)
    parser_names = JSON.parse(parser_names)
    parsers = parser_names&.map do |parser_name|
      raise ArgumentError, "Parser '#{parser_name}' is not defined." unless self.class.parsers.key?(parser_name)

      self.class.parsers[parser_name][:lambda]
    end || []
    parsers.each do |parser|
      value = parser.call(value) if parser
    end
    value
  end

  def unprocessable_fields(header_row)
    mappings = mapping || []
    mapped_headers = mappings.map { |m| m['csv_column_name'] }

    header_row - mapped_headers
  end

  def keys
    mappings = mapping || []
    keys = mappings.select { |m| m['key'] }
    keys.map { |k| k['model_property'] }
  end

  private

  class << self
    def parsers
      @parsers ||= {
        'trim' => { lambda: lambda(&:strip), description: 'Removes leading and trailing whitespace.' },
        'strip_html_tags' => { lambda: ->(value) { value&.gsub(/<\/?[^>]*>/, '') }, description: 'Removes HTML tags from the text.' },
        'remove_leading_hash' => { lambda: ->(value) { value&.gsub(/#\b/, '') || '' }, description: 'Removes leading hash symbols (#).' },
        'spaces_to_commas' => { lambda: ->(value) { value&.gsub(/\s+/, ',') }, description: 'Replaces spaces with commas.' },
        'split_to_first' => { lambda: ->(value) { value.split(',').first }, description: 'Takes the first value from a comma-separated list.' },
        'split_to_last' => { lambda: ->(value) { value.split(',').last }, description: 'Takes the last value from a comma-separated list.' },
        'european_date' => { lambda: ->(value) { DateTime.strptime(value, '%d.%m.%Y') }, description: 'Parses a date in European format (DD.MM.YYYY).' },
        'us_date' => { lambda: ->(value) { DateTime.strptime(value, '%m-%d-%Y') }, description: 'Parses a date in US-American format (MM-DD-YYYY).' },
        'remove_non_float_chars' => { lambda: ->(value) { value&.gsub(/[^0-9.-]/, '') }, description: 'Removes all characters that are not numeric or a dot or a dash.' },
        'remove_chars_before_dash' => { lambda: ->(value) { value.sub(/^.*?-/, '-') }, description: 'Removes all characters that are on the left from a dash.' }
      }
    end
  end

  def validate_required_model_properties
    required_properties = %w[title lat lon]
    mappings = mapping || []
    missing_properties = required_properties - mappings.map { |m| m['model_property'] }

    return unless missing_properties.any?

    errors.add(:mapping, "is missing required properties: #{missing_properties.join(', ')}")
  end

  def validate_unique_model_properties
    return unless mapping.present?

    model_properties = mapping.map { |m| m['model_property'] }.compact
    duplicates = model_properties.select { |property| model_properties.count(property) > 1 }.uniq.compact.reject(&:empty?)
    return unless duplicates.any?

    errors.add(:mapping, "contains duplicate model properties: #{duplicates.join(', ')}")
  end

  def ensure_id_is_key
    mappings = mapping || []
    id_mapping = mappings.find { |m| m['model_property'] == 'id' }
    id_mapping['key'] = true if id_mapping && !id_mapping['key']
    self.mapping = mappings
  end

  def validate_parsers
    return unless mapping.present?

    invalid_parsers = mapping.flat_map { |m| process_parsers(m['parsers']) }.compact

    errors.add(:mapping, "contains undefined parsers: #{invalid_parsers.uniq.join(', ')}") if invalid_parsers.any?
  end

  def process_parsers(parsers)
    return [] if parsers.nil?

    parsed_parsers = parse_and_validate_format(parsers)
    return [] unless parsed_parsers

    parsed_parsers.reject { |parser| self.class.parsers.key?(parser) }
  end

  def parse_and_validate_format(parsers)
    parsers = JSON.parse(parsers) if parsers.is_a?(String)
    unless parsers.is_a?(Array) && parsers.all? { |p| p.is_a?(String) }
      errors.add(:mapping, "contains invalid parser format: #{parsers}")
      return nil
    end
    parsers
  rescue JSON::ParserError
    errors.add(:mapping, "contains invalid parser format: #{parsers}")
    nil
  end
end
