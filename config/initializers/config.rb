# frozen_string_literal: true

# Reading from ENV within the application code can lead to runtime errors due to
# misconfiguration. To avoid that, we are loading it at boot time to application's configuration.
Rails.application.configure do
  config.default_max_page_size = ENV.fetch('MAX_PAGE_SIZE', 100).to_i
  config.users_per_role = ENV.fetch('USERS_PER_ROLE', 10).to_i
  config.allowed_domains = ENV['ALLOWED_DOMAINS'].delete(' ').split(',').freeze

  config.azure_tenant_id = ENV['AZURE_TENANT_ID']
  config.azure_client_id = ENV['AZURE_CLIENT_ID']
end
