# frozen_string_literal: true

class CreateAdminToolkitPctCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_pct_costs, id: :uuid do |t|
      t.integer :index, null: false, index: { unique: :case_insensitive_comparison }
      t.integer :min, null: false
      t.integer :max, null: false

      t.timestamps
    end
  end
end
