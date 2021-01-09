# frozen_string_literal: true

# Fame goes to Laila Winner, https://robots.thoughtbot.com/validating-json-schemas-with-an-rspec-matcher

# JSON Schema infered with https://www.jsonschema.net/

RSpec::Matchers.define :match_response_schema do |schema,format|
  match do |response|
    schema_directory = "#{Dir.pwd}/spec/support/api/"
    schema_path = "#{schema_directory}/#{schema}.#{format}"
    JSON::Validator.validate!(schema_path, response.body, strict: true)
  end
end
