# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'puma', '~> 6'
gem 'rails', '~> 7.2'
gem 'sassc-rails'
gem 'terser', '~> 1.1', '>= 1.1.12'

gem 'friendly_id'

gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5'
# Use ActiveModel has_secure_password
gem 'bcrypt'
gem 'deep_cloneable', '~> 3'

# custom
gem 'cancancan'
gem 'devise'
gem 'exception_notification'
gem 'foundation-icons-sass-rails'
gem 'foundation-rails', '6.6.2.0'
gem 'geocoder'
gem 'haml-rails'
gem 'jquery-rails'
gem 'jquery-turbolinks'
gem 'jquery-ui-rails', '~> 7', git: 'https://github.com/jquery-ui-rails/jquery-ui-rails.git', branch: 'master', ref: '27a942cfa3686716ff85a3cb60f1f885a00e35dc'
gem 'kaminari'
gem 'mysql2'
gem 'rack-attack'
gem 'rack-cors'
gem 'secure_headers', '6.5.0'
gem 'select2-rails'
gem 'simple_form'
gem 'sprockets'
gem 'sprockets-rails', require: 'sprockets/railtie'

gem 'image_processing'
gem 'mini_racer', '0.16', platforms: :ruby
gem 'nokogiri'

gem 'acts-as-taggable-on', '~> 11'
gem 'color-generator'
gem 'mini_magick'
gem 'mobility', '~> 1.2'
gem 'rubyzip'
gem 'tinymce-rails', '~> 5'
gem 'turnout'

gem 'net-smtp'

gem 'concurrent-ruby', '1.3.4' # https://github.com/rails/rails/issues/54260, remove after upgrade to 7.2

group :staging, :production do
  gem 'passenger', '~> 6'
end

gem 'coveralls_reborn', '~> 0', require: false

group :development, :test do
  gem 'bundler-audit', require: false
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'ruby_audit', require: false

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'capybara-chromedriver-logger'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'json-schema'
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'simplecov-small-badge', require: false
  gem 'webdrivers', '~> 5'

  gem 'webmock'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3'
  gem 'web-console', '~> 4'

  gem 'capistrano', '~> 3', require: false
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm'

  gem 'letter_opener'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'brakeman', require: false
end

gem 'activerecord-session_store', '~> 2.1'
