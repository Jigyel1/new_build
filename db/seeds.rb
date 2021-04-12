# frozen_string_literal: true

exception = <<~MESSAGE
  The Rails environment is running in production mode!#{' '}
  Seeds available only for development or test.
  If you are seeding in test/staging servers, pass a TEST=true flag as an argument.
MESSAGE

abort(exception) if Rails.env.production? && !ActiveModel::Type::Boolean.new.cast(ENV['TEST'])

Role.names.each_key do |role|
  Role.create!(name: role)
end

User.create!(
  email: 'ym@selise.ch',
  password: 'Selise21',
  role: Role.find_by(name: :team_expert),
  address_attributes: {
    street: 'Haldenstrasse',
    street_no: 23,
    zip: '8006',
    city: 'Zurich'
  },
  profile_attributes: {
    firstname: 'Yogesh',
    lastname: 'Mongar',
    salutation: 'Mr',
    phone: '97517587828',
    department: 'Sales'
  }
)
