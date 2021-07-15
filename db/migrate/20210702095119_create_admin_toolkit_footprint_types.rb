# frozen_string_literal: true

class CreateAdminToolkitFootprintTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_footprint_types, id: :uuid do |t|
      t.string :provider
      t.integer :index

      t.timestamps
    end
  end
end
