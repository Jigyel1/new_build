# frozen_string_literal: true

class AddNewFieldsToAdminToolkitProjectCosts < ActiveRecord::Migration[6.1]
  def change # rubocop:disable Metrics/SeliseMethodLength
    safety_assured do
      change_table :admin_toolkit_project_costs, bulk: true do |t|
        t.decimal :cpe_hfc
        t.decimal :cpe_ftth
        t.decimal :olt_cost_per_customer
        t.decimal :old_cost_per_unit
        t.decimal :patching_cost
        t.decimal :mrc_standard
        t.decimal :mrc_high_tiers
        t.float :high_tiers_product_share
        t.integer :hfc_payback
        t.integer :ftth_payback
      end
    end
  end
end
