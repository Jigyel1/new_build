# frozen_string_literal: true

FactoryBot.define do
  factory :projects_pct_cost, class: 'Projects::PctCost' do
    project_cost { 1199 }
    socket_installation_cost { 570 }
    arpu { 45 }
    penetration_rate { 7.45 }
    lease_cost { 399 }
    payback_period { 'Five Years Three Months' }
  end
end
