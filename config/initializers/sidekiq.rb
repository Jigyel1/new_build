# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_HOST'], password: ENV['REDIS_SECRET']  }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_HOST'], password: ENV['REDIS_SECRET']  }
end
