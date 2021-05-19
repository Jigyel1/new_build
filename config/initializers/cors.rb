# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

unless ActiveModel::Type::Boolean.new.cast(ENV['ENABLE_CORS'])
  Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: true, logger: (-> { Rails.logger }) do
    allow do
      origins '*'
      resource(
        '*',
        headers: :any,
        methods: :all,
        expose: %w[Authorization],
        max_age: 600
      )
    end
  end
end
