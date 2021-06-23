# frozen_string_literal: true

Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  config.enabled = ActiveModel::Type::Boolean.new.cast(ENV['ENABLE_ROLLBAR'])
  config.environment = ENV['ROLLBAR_ENV'].presence || Rails.env

  config.use_sidekiq
  config.sidekiq_threshold = 1
end
