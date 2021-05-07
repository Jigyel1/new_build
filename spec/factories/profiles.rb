# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    salutation { :mr }
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }
    department { :marketing }

    trait :with_user do
      user { create(:user, role: Role.first) }
    end
  end
end
