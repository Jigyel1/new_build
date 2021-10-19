# frozen_string_literal: true

# To run the seed file either invoke it through
#   :=> `rails db:seed` or
#   :=> `rails db:dev_setup`

require 'faker' unless Rails.env.production?

exception = <<~MESSAGE
  The Rails environment is running in production mode!
  Seeds available only for development or test.
  If you are seeding in test/staging servers, pass a TEST=true flag as an argument.
MESSAGE

abort(exception) if Rails.env.production? && !ENV.fetch('TEST', '').to_b

def address_attributes
  {
    street: Faker::Address.street_name,
    street_no: Faker::Address.building_number,
    zip: Faker::Address.zip,
    city: Faker::Address.city
  }
end

def profile_attributes(name)
  firstname, lastname = name.split('.')
  {
    firstname: firstname,
    lastname: lastname || firstname.reverse,
    salutation: Profile.salutations.keys.sample,
    phone: Faker::PhoneNumber.phone_number,
    department: Rails.application.config.user_departments.sample
  }
end

[
  # Internal Users
  ['ym@selise.ch', :super_user],
  ['suraj.sunar@selise.ch', :super_user],
  ['jigyel.dorji@selise.ch', :super_user],
  ['arijit.saha@selise.ch', :super_user],
  ['jigyel.dorji@selise.ch', :super_user],
  ['lhatul.wangmo@selise.ch', :super_user],
  ['sujata.pradhan@selise.ch', :administrator],
  ['chimi.wangchuk@selise.ch', :administrator],
  ['upali.choden@selise.ch', :administrator],
  ['nahian.kabir@selise.ch', :administrator],

  # For QA test
  ['sujata.pradhan+admin@selise.ch', :kam],
  ['sujata.pradhan+cm@selise.ch', :presales],
  ['sujata.pradhan+kam@selise.ch', :management],

  # External Users
  ['stefan.fitsch@upc.ch', :super_user],
  ['michael.egger@upc.ch', :administrator],
  ['danijela.martinovic@upc.ch', :administrator]
].each do |array|
  email, role = array
  User.create!(
    email: email,
    password: 'Selise21',
    role: Role.find_by(name: role),
    address_attributes: address_attributes,
    profile_attributes: profile_attributes(email.split('@').first),
    invitation_token: SecureRandom.hex
  ).then(&:accept_invitation!)
rescue ActiveRecord::RecordInvalid => e
  puts "#{e} for user with email(#{email})"
end
