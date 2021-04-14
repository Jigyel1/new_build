# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    name { :team_expert }

    trait :kam do
      name { :kam }
    end
  end
end
