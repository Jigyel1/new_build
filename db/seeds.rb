# frozen_string_literal: true

# To run the seed file either invoke it through
#   :=> `rails db:seed` or
#   :=> `rails db:dev_setup`

require 'faker'
require_relative '../permissions/bulk_updater'

exception = <<~MESSAGE
  The Rails environment is running in production mode!
  Seeds available only for development or test.
  If you are seeding in test/staging servers, pass a TEST=true flag as an argument.
MESSAGE

abort(exception) if Rails.env.production? && !ActiveModel::Type::Boolean.new.cast(ENV['TEST'])

Role.names.each_key do |name|
  role = Role.find_or_create_by!(name: name)
  Permissions::BulkUpdater.new(role: role).call
rescue NoMethodError
  puts "No policy configuration for #{role.name}"
end

%w[ym sk cw lw].each do |email_prefix|
  User.create!(
    email: "#{email_prefix}@selise.ch",
    password: ENV['TEST_USER_PASSWORD'],
    role: Role.find_by(name: Role.names.keys.sample),
    address_attributes: {
      street: Faker::Address.street_name,
      street_no: Faker::Address.building_number,
      zip: Faker::Address.zip,
      city: Faker::Address.city
    },
    profile_attributes: {
      firstname: email_prefix,
      lastname: email_prefix.reverse,
      salutation: Profile.salutations.keys.sample,
      phone: Faker::PhoneNumber.phone_number,
      department: Profile::VALID_DEPARTMENTS.sample
    }
  )
rescue ActiveRecord::RecordInvalid => e
  puts "#{e} for user with email(#{email_prefix}@selise.ch)" # rubocop:disable Rails/Output
end
