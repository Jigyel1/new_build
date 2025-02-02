# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_pct_cost, class: 'AdminToolkit::PctCost' do
    index { 0 }
    min { 1 }
    max { 2500 }
  end
end
