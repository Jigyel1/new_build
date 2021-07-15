# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_pct_cost, class: 'AdminToolkit::PctCost' do
    index { 0 }
    min { 0 }
    max { 2500 }
    header { 'Less than CHF 2.5K' }
  end
end
