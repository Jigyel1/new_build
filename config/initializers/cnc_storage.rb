# frozen_string_literal: true

Cnc::Storage.configure do |config|
  config.bucket = Rails.application.credentials.dig(:azure_storage, :container)
  config.endpoint = 'https://fra1.digitaloceanspaces.com'
  config.secret_access_key = Rails.application.credentials.dig(:azure_storage, :storage_account_name)
  config.access_key_id = Rails.application.credentials.dig(:azure_storage, :storage_access_key)
  config.region = 'fra1'
  config.cdn_url = 'https://assets.selise.tech'
end
