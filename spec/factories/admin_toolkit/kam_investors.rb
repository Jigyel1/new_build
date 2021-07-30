# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_kam_investor, class: 'AdminToolkit::KamInvestor' do
    investor_id { Faker::Number.hexadecimal }
    investor_description { Faker::Lorem.sentence }
  end
end
