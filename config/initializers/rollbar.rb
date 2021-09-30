# frozen_string_literal: true

Rollbar.configure do |config|
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN']
  config.enabled = ENV.fetch('ENABLE_ROLLBAR', '').to_b
  config.environment = ENV['ROLLBAR_ENV'].presence || Rails.env

  config.use_sidekiq
  config.sidekiq_threshold = 1
end
