# frozen_string_literal: true

require_relative '../../lib/file_parser'

# Reading from ENV within the application code can lead to runtime errors due to
# misconfiguration. To avoid that, we are loading it at boot time to application's configuration.
Rails.application.configure do
  config.test_server = ENV.fetch('TEST_SERVER', '').to_b
  config.default_max_page_size = ENV.fetch('MAX_PAGE_SIZE', 100).to_i
  config.users_per_role = ENV.fetch('USERS_PER_ROLE', 10).to_i
  config.allowed_domains = ENV['ALLOWED_DOMAINS'].delete(' ').split(',').freeze
  config.host_url = ENV.fetch('HOST_URL', nil)

  config.azure_authorization_endpoint = ENV.fetch('AZURE_AUTHORIZATION_ENDPOINT', nil)
  config.azure_callback_uri = ENV.fetch('AZURE_CALLBACK_URI', nil)
  config.azure_tenant_id = ENV.fetch('AZURE_TENANT_ID', nil)
  config.azure_client_id = ENV.fetch('AZURE_CLIENT_ID', nil)
  config.azure_secret = ENV.fetch('AZURE_SECRET', nil)

  config.gis_url = ENV.fetch('GIS_URL', nil)
  config.gis_url_static = ENV.fetch('GIS_URL_STATIC', nil)
  config.info_manager_url = ENV.fetch('INFO_MANAGER_URL', nil)

  config.mail_sender = ENV.fetch('MAIL_SENDER', nil)

  config.available_permissions = FileParser.parse { 'config/available_permissions.yml' }
  config.role_permissions = FileParser.parse { 'config/permissions.yml' }
  config.activity_actions = FileParser.parse { 'config/actions.yml' }
  config.user_departments = FileParser.parse { 'config/departments.yml' }

  config.kam_regions = FileParser.parse { 'config/kam_regions.yml' }
  config.translation_keys = Dir.glob(Rails.root.join('config/translation_keys/*.yml')).flat_map do |file|
    FileParser.parse { file }
  end.reduce({}, :merge)
end
