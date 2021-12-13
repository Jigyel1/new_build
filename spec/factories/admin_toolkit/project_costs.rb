# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_project_cost, class: 'AdminToolkit::ProjectCost' do
    initialize_with { AdminToolkit::ProjectCost.instance }

    socket_installation_rate { 90.55 }
    standard_connection_cost { 399.40 }
    arpu { 45.66 }

    mrc_standard { 20.0 }
    mrc_high_tiers { 37.0 }
    high_tiers_product_share { 20 }
    hfc_payback { 36 }
  end
end
