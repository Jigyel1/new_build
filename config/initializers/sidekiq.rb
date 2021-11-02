# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { namespace: ENV['REDIS_NAMESPACE'], url: ENV['REDIS_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: ENV['REDIS_NAMESPACE'], url: ENV['REDIS_URL'] }
end

Sidekiq::Statistic.configure do |config|
  config.max_timelist_length = 250_000
end
