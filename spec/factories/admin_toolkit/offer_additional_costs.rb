# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_offer_additional_cost, class: 'AdminToolkit::OfferAdditionalCost' do
    name { { en: 'TESTER' } }
    additional_cost_type { 'Discount' }
    value { -1234 }
  end
end
