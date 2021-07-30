# frozen_string_literal: true

class CreateAdminToolkitPenetrations < ActiveRecord::Migration[6.1]
  def change # rubocop:disable Metrics/SeliseMethodLength
    create_table :admin_toolkit_penetrations, id: :uuid do |t|
      t.string :zip, null: false, index: true, unique: true
      t.string :city, null: false
      t.float :rate, null: false

      t.references(
        :competition,
        null: false,
        foreign_key: { to_table: :admin_toolkit_competitions },
        type: :uuid
      )

      t.references(
        :kam_region,
        null: false,
        foreign_key: { to_table: :admin_toolkit_kam_regions },
        type: :uuid
      )

      t.boolean :hfc_footprint, null: false
      t.string :type, null: false

      t.timestamps
    end
  end
end
