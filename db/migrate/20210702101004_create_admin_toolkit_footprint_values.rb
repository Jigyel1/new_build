# frozen_string_literal: true

class CreateAdminToolkitFootprintValues < ActiveRecord::Migration[6.1]
  def change # rubocop:disable Metrics/SeliseMethodLength
    create_table :admin_toolkit_footprint_values, id: :uuid do |t|
      t.string :project_type, null: false

      t.references(
        :footprint_building,
        null: false,
        foreign_key: { to_table: :admin_toolkit_footprint_buildings },
        type: :uuid
      )

      t.references(
        :footprint_type,
        null: false,
        foreign_key: { to_table: :admin_toolkit_footprint_types },
        type: :uuid
      )

      t.timestamps
    end
  end
end
