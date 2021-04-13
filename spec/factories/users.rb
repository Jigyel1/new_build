# frozen_string_literal: true

require 'pry'

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "qa+#{n}@selise.ch" }
    password { 'Selise21' }
    active { true }

    trait :inactive do
      active { false }
    end

    after(:build) do |user|
      !user.profile && user.profile = build(:profile)
    end

    Role.names.each_key do |name|
      trait name do
        role_id { Role.find_or_create_by!(name: name).id }
      end
    end
  end
end
