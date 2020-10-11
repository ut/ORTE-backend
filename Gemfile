# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.4.4'
gem 'puma', '~> 4'
# seg fault with sassc 2.3.0
gem 'sassc', '~> 2.2.1'
gem 'sassc-rails'
gem 'uglifier'


gem 'coffee-rails'
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt'

# custom
gem 'cancancan'
gem 'devise'
gem 'exception_notification'
gem 'foundation-icons-sass-rails'
gem 'foundation-rails', '~> 6'
gem 'sprockets', '>= 3.0.0'
gem 'sprockets-es6'
gem 'haml-rails', '~> 2.0'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-turbolinks'
gem 'kaminari'
gem 'rack-attack'
gem 'secure_headers'
gem 'rack-cors'
gem 'settingslogic'
gem 'simple_form'
gem 'select2-rails'

# gem 'mini_racer', '0.2.15', platforms: :ruby
gem 'mini_racer', platforms: :ruby
gem 'image_processing', '~> 1.2'

gem 'color-generator'

gem 'tinymce-rails'

gem 'acts-as-taggable-on', '~> 6.0'

group :staging, :production do
  # gem 'pg'
  gem 'mysql2'
  gem 'passenger'
end

gem 'coveralls_reborn', '~> 0.15', require: false

group :development, :test, :localtest do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3'
  gem 'webdrivers', '~> 4.0'
  gem 'capybara-chromedriver-logger'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'rspec_junit_formatter'
  gem 'sqlite3'
  gem 'json-schema'
  gem 'webmock'
end


group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'

  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rails', group: :development
  gem 'capistrano-rvm'

  gem 'letter_opener'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'brakeman', require: false
  gem 'rubycritic', require: false
end
