# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.middleware.insert_before 0, Rack::Cors, debug: true, logger: (-> { Rails.logger }) do
  allow do
    origins 'localhost:4200', 'localhost:3000', 'new-build.selise.dev', 'new-build',
            'http://localhost:4200', 'http://localhost:3000',
            'http://new-build.selise.dev', 'http://new-build'
    resource(
      '*',
      headers: :any,
      methods: :all,
      max_age: 600,
      credentials: true
    )
  end
end

Rails.application.config.action_controller.forgery_protection_origin_check = false
