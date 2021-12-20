# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_offer_price, class: 'AdminToolkit::OfferPrice' do
    index { 0 }
    min_apartments { 0 }
    max_apartments { 5 }
    name { { en: 'TESTER x TESTER' } }
    value { 3000 }
  end
end
