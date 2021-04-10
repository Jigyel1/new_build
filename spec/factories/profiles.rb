# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    user { nil }
    salutation { :mr }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }
    department { Faker::Commerce.department }
  end
end
