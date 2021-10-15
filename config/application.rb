# frozen_string_literal: true

require_relative 'boot'

require 'rails'
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

# For GraphiQL
require 'sprockets/railtie' if Rails.env.development?

%w[array float string].each { |klass| require_relative "../lib/#{klass}" }

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NewBuild
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # https://guides.rubyonrails.org/engines.html#overriding-models-and-controllers
    overrides = Rails.root.join('app/overrides')
    Rails.autoloaders.main.ignore(overrides)
    config.to_prepare do
      ActiveStorage::Attachment.include ActiveStorageAttachmentExtension

      Dir.glob("#{overrides}/**/*_override.rb").each do |override|
        load override
      end
    end

    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('permissions/*')
    config.eager_load_paths << Rails.root.join('etl')

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.lograge.enabled = Rails.env.production?

    config.default_locale = :de
    config.time_zone = 'Europe/Amsterdam'

    # Logidze uses DB functions and triggers, hence you need to use SQL format for a schema dump
    config.active_record.schema_format = :sql
    config.logidze.ignore_log_data_by_default = true

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use(
      ActionDispatch::Session::CookieStore,
      key: '_new_build_session',
      expire_after: 30.days,
      serializer: :json
    )

    # https://andycroll.com/ruby/opt-out-of-google-floc-tracking-in-rails
    config.action_dispatch.default_headers['Permissions-Policy'] = 'interest-cohort=()'
  end
end
