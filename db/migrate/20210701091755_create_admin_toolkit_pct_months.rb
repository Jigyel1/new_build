# frozen_string_literal: true

class CreateAdminToolkitPctMonths < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_pct_months, id: :uuid do |t|
      t.integer :index
      t.integer :min
      t.integer :max
      t.string :header

      t.timestamps
    end
  end
end
