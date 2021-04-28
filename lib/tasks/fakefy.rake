# frozen_string_literal: true

# Run `rails db:seed` before to populate the roles first.
# @param USERS [Integer] How many users do you want to seed.
#
namespace :fakefy do
  desc 'seeding random users for test/development purposes'
  task load: :environment do
    puts "seeding #{ENV['USERS']} users..."

    production_server = Rails.env.production? && !ActiveModel::Type::Boolean.new.cast(ENV['TEST'])
    abort('You are running this task in production which is not allowed!') if production_server

    count = ENV['USERS'].to_i

    generator = Test::AttributesGenerator.new(count)
    User.insert_all(generator.users_hash)
    Profile.insert_all(generator.profiles_hash)
    Address.insert_all(generator.addresses_hash)

    # Manually update counter cache users_count for roles
    Role.find_each { |role| Role.reset_counters(role.id, :users) }
  end
end
