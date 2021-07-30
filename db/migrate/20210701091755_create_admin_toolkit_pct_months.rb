# frozen_string_literal: true

class CreateAdminToolkitPctMonths < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_pct_months, id: :uuid do |t|
      t.integer :index, null: false, index: true
      t.integer :min, null: false
      t.integer :max, null: false

      t.timestamps
    end
  end
end
