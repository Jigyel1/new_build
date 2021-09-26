# frozen_string_literal: true

class CreateAdminToolkitFootprintTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_footprint_types, id: :uuid do |t|
      t.string :provider, null: false
      t.integer :index, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
