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

    after(:build) do |activity|
      activity.log_data = {
        owner_email: activity.owner.email,
        recipient_email: activity.recipient.try(:email)
      } if activity.log_data.blank?
    end
  end
end
