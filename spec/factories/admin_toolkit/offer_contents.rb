# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_offer_content, class: 'AdminToolkit::OfferContent' do
    title { { en: 'TESTER' } }
    content { 'TESTER_TESTER_TESTER' }
  end
end
