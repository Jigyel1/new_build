# frozen_string_literal: true

require_relative '../../lib/file_parser'

# Reading from ENV within the application code can lead to runtime errors due to
# misconfiguration. To avoid that, we are loading it at boot time to application's configuration.
Rails.application.configure do
  config.test_server = ENV.fetch('TEST_SERVER', '').to_b
  config.default_max_page_size = ENV.fetch('MAX_PAGE_SIZE', 100).to_i
  config.users_per_role = ENV.fetch('USERS_PER_ROLE', 10).to_i
  config.allowed_domains = ENV['ALLOWED_DOMAINS'].delete(' ').split(',').freeze

  config.azure_authorization_endpoint = ENV['AZURE_AUTHORIZATION_ENDPOINT']
  config.azure_callback_uri = ENV['AZURE_CALLBACK_URI']
  config.azure_tenant_id = ENV['AZURE_TENANT_ID']
  config.azure_client_id = ENV['AZURE_CLIENT_ID']
  config.azure_secret = ENV['AZURE_SECRET']

  config.gis_url = ENV['GIS_URL']
  config.info_manager_url = ENV['INFO_MANAGER_URL']

  config.mail_sender = ENV['MAIL_SENDER']

  config.available_permissions = FileParser.parse { 'config/available_permissions.yml' }
  config.role_permissions = FileParser.parse { 'config/permissions.yml' }
  config.activity_actions = FileParser.parse { 'config/actions.yml' }
  config.user_departments = FileParser.parse { 'config/departments.yml' }

  config.kam_regions = FileParser.parse { 'config/kam_regions.yml' }
  config.translation_keys = Dir.glob(Rails.root.join('config/translation_keys/*.yml')).flat_map do |file|
    FileParser.parse { file }
  end.reduce({}, :merge)
end
