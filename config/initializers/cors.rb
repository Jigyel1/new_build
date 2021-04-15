# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# enable CORS for test/staging servers
if !ActiveModel::Type::Boolean.new.cast(ENV['PRODUCTION_SERVER'])
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'https://new-build.selise.ch'
      resource(
        '*',
        headers: :any,
        methods: :all,
        expose: %w(Authorization),
        max_age: 600
      )
    end
  end
end
