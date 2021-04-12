# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'qa@selise.ch' }
    password { 'Selise21' }

    after(:build) do |user|
      !user.profile && user.profile = build(:profile)
    end
  end
end
