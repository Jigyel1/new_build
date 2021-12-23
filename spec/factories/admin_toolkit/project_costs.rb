# frozen_string_literal: true

FactoryBot.define do
  factory :admin_toolkit_project_cost, class: 'AdminToolkit::ProjectCost' do
    initialize_with { AdminToolkit::ProjectCost.instance }

    socket_installation_rate { 300 }
    standard_connection_cost { 399.40 }
    arpu { 45.66 }

    mrc_standard { 20.0 }
    mrc_high_tiers { 37.0 }
    mrc_sfn { 6.0 }
    high_tiers_product_share { 20 }
    hfc_payback { 3 * 12 }
    ftth_cost { 1190 }
    iru_sfn { 1695 }

    cpe_ftth { 150 }
    cpe_hfc { 150 }
    olt_cost_per_unit { 50 }
    olt_cost_per_customer { 104 }
    patching_cost { 130 }

    ftth_payback { 20 * 12 }
  end
end
