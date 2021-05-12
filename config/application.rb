# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'devise'
require 'devise/strategies/database_authenticatable'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'

# TODO: @chimmi
#   Uncomment the below three lines while testing
#   This is to have the email delivered in the foreground instead of sending the job to redis.
#   Once ready, remove it and raise a PR.
#
# require 'sidekiq/testing'
# Sidekiq::Testing.fake! # fake is the default mode
# Sidekiq::Testing.inline!

# For GraphiQL
require 'sprockets/railtie'

# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NewBuild
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('permissions/*')

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.lograge.enabled = true

    config.default_locale = :de
    config.time_zone = 'Europe/Amsterdam'

    # Logidze uses DB functions and triggers, hence you need to use SQL format for a schema dump
    config.active_record.schema_format = :sql
    config.logidze.ignore_log_data_by_default = true

    config.middleware.use ActionDispatch::Cookies
    if Rails.env.production?
      config.middleware.use(
        ActionDispatch::Session::CacheStore,
        key: '_new_build_session',
        expire_after: 30.days,
        domain: :all,
        secure: true
      )
    else
      config.middleware.use ActionDispatch::Session::CookieStore, key: '_new_build_session'
    end
  end
end
