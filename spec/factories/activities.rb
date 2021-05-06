# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    owner { nil }
    recipient { nil }
    verb { 'MyString' }

    trait :yesterday do
      created_at { Date.yesterday }
    end

    trait :tomorrow do
      created_at { Date.tomorrow }
    end
  end
end
