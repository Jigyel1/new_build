# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { namespace: ENV.fetch('REDIS_NAMESPACE', nil), url: ENV.fetch('REDIS_URL', nil) }
end

Sidekiq.configure_client do |config|
  config.redis = { namespace: ENV.fetch('REDIS_NAMESPACE', nil), url: ENV.fetch('REDIS_URL', nil) }
end
