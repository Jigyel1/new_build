# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_cost_threshold, class: 'AdminToolkit::CostThreshold' do
    not_exceeding { 5000 }
    exceeding { 10_000 }
  end
end
