# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_competition, class: 'AdminToolkit::Competition' do
    name { 'FTTH Swisscom' }
    factor { 0.9 }
    lease_rate { 75 }
    description { 'With only HFC of the EVU (Open Access Layer 1 & 2; tendency rather Salt & Sunrise)' }

    trait :swisscom_dsl do
      name { 'Swisscom DSL' }
    end
  end
end
