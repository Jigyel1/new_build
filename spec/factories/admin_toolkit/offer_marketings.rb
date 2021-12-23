# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_offer_marketing, class: 'AdminToolkit::OfferMarketing' do
    activity_name { { en: 'TESTER' } }
    value { 1234 }
  end
end
