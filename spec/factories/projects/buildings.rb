# frozen_string_literal: true

FactoryBot.define do
  factory :building, class: 'Projects::Building' do
    name { Faker::Lorem.word }
    assignee { nil }
    apartments_count { 1 }

    after(:build) do |building|
      building.address = build(:address) unless building.address
    end
  end
end
