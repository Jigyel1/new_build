# frozen_string_literal: true

# To run the seed file either invoke it through
#   :=> `rails db:seed` or
#   :=> `rails db:dev_setup`

require 'faker'

exception = <<~MESSAGE
  The Rails environment is running in production mode!
  Seeds available only for development or test.
  If you are seeding in test/staging servers, pass a TEST=true flag as an argument.
MESSAGE

abort(exception) if Rails.env.production? && !ActiveModel::Type::Boolean.new.cast(ENV['TEST'])

def address_attributes
  {
    street: Faker::Address.street_name,
    street_no: Faker::Address.building_number,
    zip: Faker::Address.zip,
    city: Faker::Address.city
  }
end

def profile_attributes(email_prefix)
  {
    firstname: email_prefix,
    lastname: email_prefix.reverse,
    salutation: Profile.salutations.keys.sample,
    phone: Faker::PhoneNumber.phone_number,
    department: Rails.application.config.user_departments.sample
  }
end

{ ym: :super_user, sk: :administrator, cw: :team_expert, lw: :kam }.each_pair do |email_prefix, role|
  User.create!(
    email: "#{email_prefix}@selise.ch",
    password: 'Selise21',
    role: Role.find_by(name: role),
    address_attributes: address_attributes,
    profile_attributes: profile_attributes(email_prefix.to_s)
  )
rescue ActiveRecord::RecordInvalid => e
  puts "#{e} for user with email(#{email_prefix}@selise.ch)"
end
