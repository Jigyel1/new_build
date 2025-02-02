# frozen_string_literal: true

class CreateAdminToolkitPenetrationCompetitions < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_penetration_competitions, id: :uuid do |t|
      t.references :penetration, null: false, foreign_key: { to_table: :admin_toolkit_penetrations }, type: :uuid
      t.references :competition, null: false, foreign_key: { to_table: :admin_toolkit_competitions }, type: :uuid

      t.timestamps
    end
  end
end
