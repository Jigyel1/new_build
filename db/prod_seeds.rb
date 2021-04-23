# frozen_string_literal: true

# To run the seed file for PROD run
#   :=> `rails db:prod_setup`

require_relative '../permissions/bulk_updater'

Role.names.each_key do |name|
  role = Role.find_or_create_by!(name: name)
  Permissions::BulkUpdater.new(role: role).call
rescue NoMethodError
  puts "No policy configuration for #{role.name}"
end
