# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    owner { nil }
    recipient { nil }
    action { 'profile_updated' }
    trackable_type { 'User' }

    trait :yesterday do
      created_at { Date.yesterday }
    end

    trait :tomorrow do
      created_at { Date.tomorrow }
    end
  end
end
