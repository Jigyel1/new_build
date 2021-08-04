# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[6.1]
  def change # rubocop:disable Metrics/SeliseMethodLength
    create_table :projects, id: :uuid do |t|
      t.string :name
      t.string :external_id, null: false
      t.string :project_nr
      t.string :type
      t.string :category
      t.string :status
      t.string :landlord_id
      t.references :assignee, null: true, foreign_key: { to_table: :telco_uam_users }, type: :uuid

      t.string :construction_type
      t.date :construction_starts_on
      t.date :move_in_starts_on
      t.date :move_in_ends_on
      t.string :lot_number
      t.integer :buildings
      t.integer :apartments

      t.text :description
      t.text :additional_info
      t.float :coordinate_east
      t.float :coordinate_north

      t.jsonb :settings, null: false, default: {}, index: true

      t.timestamps
    end
  end
end
