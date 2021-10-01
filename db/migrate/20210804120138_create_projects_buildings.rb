# frozen_string_literal: true

class CreateProjectsBuildings < ActiveRecord::Migration[6.1]
  def change # rubocop:disable Metrics/SeliseMethodLength
    create_table :projects_buildings, id: :uuid do |t|
      t.string :name, null: false
      t.string :external_id, index: { unique: true }

      t.references :assignee, foreign_key: { to_table: :telco_uam_users }, type: :uuid
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.integer :apartments_count, null: false, default: 0
      t.date :move_in_starts_on
      t.date :move_in_ends_on

      t.jsonb :additional_details, default: {}, index: true
      t.integer :files_count, null: false, default: 0
      t.integer :tasks_count, null: false, default: 0 # excludes archived ones
      t.integer :completed_tasks_count, null: false, default: 0

      t.timestamps
    end
  end
end
