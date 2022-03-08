# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_cost_threshold, class: 'AdminToolkit::CostThreshold' do
    exceeding { 10_000 }
  end
end
