# frozen_string_literal: true

class CreateAdminToolkitKamRegions < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_kam_regions, id: :uuid do |t|
      t.references(
        :kam,
        foreign_key: { to_table: :telco_uam_users },
        type: :uuid
      )

      t.string :name, index: { unique: :case_insensitive_comparison }, null: false

      t.timestamps
    end
  end
end
