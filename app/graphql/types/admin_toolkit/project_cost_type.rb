# frozen_string_literal: true

module Types
  module AdminToolkit
    class ProjectCostType < BaseObject
      field :id, ID, null: true
      field :standard, Float, null: true
      field :arpu, Float, null: true
      field :socket_installation_rate, Float, null: true

      field :cpe_hfc, Float, null: true
      field :cpe_ftth, Float, null: true
      field :olt_cost_per_customer, Float, null: true
      field :old_cost_per_unit, Float, null: true
      field :patching_cost, Float, null: true
      field :mrc_standard, Float, null: true
      field :mrc_high_tiers, Float, null: true
      field :high_tiers_product_share, Float, null: true
      field :hfc_payback, Int, null: true
      field :ftth_payback, Int, null: true
    end
  end
end
