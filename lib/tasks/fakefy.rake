# frozen_string_literal: true

# Run `rails db:seed` before to populate the roles first.
# @param USERS [Integer] How many users do you want to seed.
#
namespace :fakefy do
  desc 'seeding random users for test/development purposes'
  task load: :environment do
    puts "seeding #{ENV['USERS']} users..."
    abort('You are running this task in production which is not allowed!') if Rails.env.production?

    count = ENV['USERS'].to_i

    generator = Test::AttributesGenerator.new(count)
    User.insert_all(generator.users_hash)
    Profile.insert_all(generator.profiles_hash)
    Address.insert_all(generator.addresses_hash)
  end
end
