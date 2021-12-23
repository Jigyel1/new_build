# frozen_string_literal: true

FactoryBot.define do
  factory :projects_pct_cost, class: 'Projects::PctCost' do
    project_cost { 1199 }
    socket_installation_cost { 570 }
    lease_cost { 399 }
    payback_period { 'Five Years Three Months' }

    trait :manually_set_payback_period do
      system_generated_payback_period { false }
    end
  end
end
