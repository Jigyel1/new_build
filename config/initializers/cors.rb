# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

if ActiveModel::Type::Boolean.new.cast(ENV['TEST_SERVER'])
  Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: true, logger: (-> { Rails.logger }) do
    allow do
      origins 'http://localhost:4200'
      resource(
        '*',
        headers: :any,
        methods: :any,
        max_age: 600,
        credentials: true
      )
    end
  end
end
