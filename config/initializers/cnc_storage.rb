Cnc::Storage.configure do |config|
  config.bucket = 'stg-assets'
  config.endpoint = 'https://fra1.digitaloceanspaces.com'
  config.secret_access_key = Rails.application.credentials.secret_access_key
  config.access_key_id = Rails.application.credentials.access_key_id
  config.region = 'fra1'
  config.cdn_url = 'https://assets.selise.tech'
end
