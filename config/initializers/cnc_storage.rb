# frozen_string_literal: true

Cnc::Storage.configure do |config|
  config.bucket = 'stg-assets'
  config.endpoint = 'https://fra1.digitaloceanspaces.com'
  config.secret_access_key = Rails.application.credentials.azure_storage[:storage_account_name]
  config.access_key_id = Rails.application.credentials.azure_storage[:storage_access_key]
  config.region = 'fra1'
  config.cdn_url = 'https://assets.selise.tech'
end
