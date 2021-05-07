# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# `PRODUCTION_SERVER` should be set to true in production server to disable cors!
unless ActiveModel::Type::Boolean.new.cast(ENV['PRODUCTION_SERVER'])
  Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: true, logger: (-> { Rails.logger })  do
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
