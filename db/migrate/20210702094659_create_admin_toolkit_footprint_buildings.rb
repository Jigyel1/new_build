# frozen_string_literal: true

class CreateAdminToolkitFootprintBuildings < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_footprint_buildings, id: :uuid do |t|
      t.integer :min
      t.integer :max
      t.integer :index
      t.string :header

      t.timestamps
    end
  end
end
