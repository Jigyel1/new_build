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

    trait :discarded do
      discarded_at { Time.current }
    end

    transient do
      with_permissions { {} }
    end

    after(:create) do |user, evaluator|
      evaluator.with_permissions.each_pair do |resource, actions|
        create(
          :permission,
          accessor: user.role,
          resource: resource,
          actions: actions.index_with { |_key| true }
        )
      end
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
