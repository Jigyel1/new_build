# frozen_string_literal: true

# To run the seed file for PROD run
#   :=> `rails db:setup_prod`

require_relative '../permissions/bulk_updater'

warning = <<~WARNING
  If you need to set default permissions with respect to the roles, send `RESET_PERMISSIONS=true`
  when calling `rails db:setup_prod`, `rails db:setup_dev` or `rails db:reset_dev`.

  Don't send that flag as true in a production setup if the permissions are already set! as
  it will reset the already created permissions. \n
WARNING

$stdout.write(warning)

Role.names.each_key do |name|
  role = Role.find_or_create_by!(name: name)
  next unless ENV.fetch('RESET_PERMISSIONS', '').to_b

  Permissions::BulkUpdater.new(role: role).call
rescue NoMethodError
  puts "No policy configuration for #{role.name}"
end

# The maximum signed integer, with 4 bytes
MAX_SIGNED = (2**31) - 1

def create_record(attributes)
  record = yield if block_given?
  return if record.persisted?

  record.assign_attributes(attributes)
  record.save!
end

FileParser.parse { 'db/description.yml' }['role_descriptions'].each do |key, value|
  role = Role.find_by!(name: key)
  role.update(description: value)
end

%w[pcts footprints label_groups competitions kam_regions].each do |file|
  puts "Loading #{file.camelize}"
  load(Rails.root.join("db/seeds/#{file}.rb"))
end
