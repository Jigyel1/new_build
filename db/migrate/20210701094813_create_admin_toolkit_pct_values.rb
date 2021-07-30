# frozen_string_literal: true

class CreateAdminToolkitPctValues < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_pct_values, id: :uuid do |t|
      t.string :status, null: false
      t.references :pct_month, null: false, foreign_key: { to_table: :admin_toolkit_pct_months }, type: :uuid
      t.references :pct_cost, null: false, foreign_key: { to_table: :admin_toolkit_pct_costs }, type: :uuid

      t.timestamps
    end
  end
end