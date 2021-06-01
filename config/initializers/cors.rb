# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

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

# Rails.application.config.action_controller.forgery_protection_origin_check = false
