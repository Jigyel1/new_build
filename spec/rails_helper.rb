# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'rspec-benchmark'
require 'support/macros'
require 'test_prof/recipes/rspec/let_it_be'
require_relative '../permissions/bulk_updater'
require 'action_policy/rspec'
require 'database_cleaner/active_record'
require 'support/activities_spec_helper'
require 'webmock/rspec'
require 'simplecov'
SimpleCov.start

ips_desc = <<~IPS_DESC
  Testing iterations per second will take more of your time in executing the specs.
  To skip running ips tests, run `bundle exec rspec --tag ~@ips` provided you add the ips tag to your spec block.

  You can pass values for the
    => number of iterations to be performed as PERFORM_AT_LEAST, defaults to 100 iterations
    => iterations to be performed within as PERFORM_WITHIN, defaults to 0.2 seconds
    => warm up for as WARMUP_FOR, defaults to 0.1 second
  For eg. PERFORM_AT_LEAST=1000 PERFORM_WITHIN=2 WARMUP_FOR=1 bundle exec rspec

  The higher values for within and warmup the more accurate average readings and more stable tests at the
  cost of longer test suite overall runtime.
IPS_DESC

$stdout.write(ips_desc)

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.include ActionView::Helpers::TranslationHelper
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.include RSpec::Benchmark::Matchers
  config.include Telco::Uam::Engine.routes.url_helpers

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.example_status_persistence_file_path = Rails.root.join('spec/failed_specs.txt')

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner.start
  end

  config.append_after do
    DatabaseCleaner.clean
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
