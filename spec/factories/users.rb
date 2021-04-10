# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'Selise21' }

    after(:build) do |user|
      !user.profile && user.profile = build(:profile)
    end
  end
end
