# frozen_string_literal: true

FactoryBot.define do
  factory :projects_pct_cost, class: 'Projects::PctCost' do
    build_cost { 5022 }
    socket_installation_cost { 570 }
    project_connection_cost { 5000 }
    penetration_rate { 7.45 }
    lease_cost { 399 }
    payback_period { '5 Years 3 Months' }
    project_cost { 5500 }
    roi { 5.3 }

    trait :manually_set_payback_period do
      system_generated_payback_period { false }
    end
  end
end
