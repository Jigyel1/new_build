# frozen_string_literal: true

# Run `rails db:seed` before to populate the roles first.
# @param TOTAL_USERS [Integer] How many users do you want to seed.
#
namespace :fakefy do
  desc 'seeding random users for test/development purposes'
  task load: :environment do
    puts "seeding #{ENV['TOTAL_USERS']} users..."
    abort('You are running this task in production which is not allowed!') if Rails.env.production?

    (1..ENV['TOTAL_USERS'].to_i).each do
      firstname = Faker::Name.first_name
      lastname = Faker::Name.last_name

      User.create!(
        email: "#{firstname}-#{lastname}@selise.ch",
        password: ENV['TEST_USER_PASSWORD'],
        role: Role.find_by(name: Role.names.keys.sample),
        address_attributes: {
          street: Faker::Address.street_name,
          street_no: Faker::Address.building_number,
          zip: Faker::Address.zip_code,
          city: Faker::Address.city
        },
        profile_attributes: {
          firstname: firstname,
          lastname: lastname,
          salutation: Profile.salutations.keys.sample,
          phone: Faker::PhoneNumber.phone_number,
          department: Profile::VALID_DEPARTMENTS.sample
        }
      )

      print '.'
    rescue ActiveRecord::RecordInvalid
      next
    end
  end
end
