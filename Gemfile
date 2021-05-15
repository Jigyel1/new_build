# frozen_string_literal: true

source 'https://rubygems.org'

plugin 'diffend'
gem 'diffend-monitor', require: 'diffend/monitor'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.3.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
gem 'sd_notify'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

gem 'multi_json'
gem 'rswag'
gem 'rswag-api'
gem 'rswag-ui'

group :development, :test do
  gem 'awesome_print'
  gem 'bullet'
  gem 'bundler-audit'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'niceql' # Don't use in production!
  gem 'pry'
  gem 'rails_best_practices'
  gem 'rspec-rails', '~> 5.0.0'
  gem 'rswag-specs'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
  gem 'rubycritic', require: false
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'solargraph'
  gem 'test-prof'
  gem 'webmock'
  gem 'webrick'
end

group :development do
  gem 'brakeman'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'graphiql-rails'
  gem 'letter_opener'
  gem 'spring'
  gem 'sprockets', '~> 3'
end

gem 'action_policy-graphql'
gem 'apollo_upload_server', '2.0.5'
gem 'azure-storage-blob', require: false
gem 'batch-loader'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'discard', '~> 1.2'
gem 'dotenv-rails'
gem 'faraday'
gem 'graphql'
gem 'graphql-batch'
gem 'graphql-query-resolver'
gem 'logidze', '~> 1.1'
gem 'lograge'
gem 'rack-cors'
gem 'recursive-open-struct'
gem 'rollbar'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'scenic'
gem 'search_object'
gem 'search_object_graphql'
gem 'sidekiq'
gem 'strong_migrations'

source 'https://gems.selise.tech' do
  gem 'cnc-storage'
  gem 'telco-uam', '0.1.2'
end

# gem "influxdb-rails", "~> 1.0"
