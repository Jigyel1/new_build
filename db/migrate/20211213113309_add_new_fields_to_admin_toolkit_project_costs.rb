# frozen_string_literal: true

class AddNewFieldsToAdminToolkitProjectCosts < ActiveRecord::Migration[6.1]
  def change # rubocop:disable Metrics/SeliseMethodLength
    safety_assured do
      change_table :admin_toolkit_project_costs, bulk: true do |t|
        t.decimal :cpe_hfc, precision: 15, scale: 2
        t.decimal :cpe_ftth, precision: 15, scale: 2
        t.decimal :olt_cost_per_customer, precision: 15, scale: 2
        t.decimal :olt_cost_per_unit, precision: 15, scale: 2
        t.decimal :patching_cost, precision: 15, scale: 2
        t.decimal :mrc_standard, precision: 15, scale: 2
        t.decimal :mrc_high_tiers, precision: 15, scale: 2
        t.decimal :iru_sfn, precision: 15, scale: 2
        t.decimal :mrc_sfn, precision: 15, scale: 2
        t.decimal :ftth_cost, precision: 15, scale: 2
        t.float :high_tiers_product_share
        t.integer :hfc_payback
        t.integer :ftth_payback
      end
    end
  end
end
