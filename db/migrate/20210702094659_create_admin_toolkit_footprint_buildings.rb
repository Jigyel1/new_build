# frozen_string_literal: true

class CreateAdminToolkitFootprintBuildings < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_footprint_buildings, id: :uuid do |t|
      t.integer :min, null: false
      t.integer :max, null: false
      t.integer :index, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
