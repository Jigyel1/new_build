# frozen_string_literal: true

require 'faker'

module Test
  class AttributesGenerator
    def initialize(count = ENV['USERS']) # rubocop:disable Rails/EnvironmentVariableAccess
      @count = count
    end

    def users_hash
      domains = Rails.application.config.allowed_domains
      n_times do |index|
        {
          id: index,
          role_id: Role.find_by(name: Role.names.keys.sample).id,
          email: "#{Faker::Name.first_name}.#{Faker::Name.last_name}@#{domains.sample}",
          created_at: Time.current,
          updated_at: Time.current,
          jti: SecureRandom.hex
        }
      end
    end

    def profiles_hash
      n_times do |index|
        {
          id: index,
          user_id: index,
          firstname: Faker::Name.first_name,
          lastname: Faker::Name.last_name,
          salutation: Profile.salutations.keys.sample,
          phone: Faker::PhoneNumber.phone_number,
          department: Profile::VALID_DEPARTMENTS.sample,
          created_at: Time.current,
          updated_at: Time.current
        }
      end
    end

    def addresses_hash
      n_times do |index|
        {
          addressable_id: index,
          addressable_type: 'Telco::Uam::User',
          street: Faker::Address.street_name,
          street_no: Faker::Address.building_number,
          zip: Faker::Address.zip_code,
          city: Faker::Address.city,
          created_at: Time.current,
          updated_at: Time.current
        }
      end
    end

    private

    def n_times
      (0..@count - 1).map do |index|
        yield(user_ids[index])
      end
    end

    def user_ids
      @user_ids ||= (1..@count).map { SecureRandom.uuid }
    end
  end
end
