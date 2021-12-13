# frozen_string_literal: true

AdminToolkit::ProjectCost.instance.update!(
  standard: 5000,
  arpu: 1.5,
  socket_installation_rate: 60,

  cpe_hfc: 150,
  cpe_ftth: 150,
  olt_cost_per_customer: 140,
  old_cost_per_unit: 50,
  patching_cost: 130,
  mrc_standard: 20,
  mrc_high_tiers: 37,
  high_tiers_product_share: 20, # in percentage
  hfc_payback: 3 * 12, # saving the time period in months
  ftth_payback: 20 * 12 # saving the time period in months
)
