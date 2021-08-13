# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[6.1]
  def self.up # rubocop:disable Metrics/SeliseMethodLength, Metrics/AbcSize
    create_table :projects, id: :uuid do |t|
      t.string :name
      t.string :external_id, null: false, index: true
      t.string :project_nr
      t.string :type
      t.string :category
      t.string :status, null: false, default: 'Technical Analysis', index: true
      t.string :assignee_type, null: false, default: 'NBO Project'

      t.references :assignee, null: true, foreign_key: { to_table: :telco_uam_users }, type: :uuid
      t.references :kam_region, null: true, foreign_key: { to_table: :admin_toolkit_kam_regions }, type: :uuid

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
      t.string :label_list, index: true, array: true

      t.jsonb :additional_details, null: false, default: {}, index: true

      t.timestamps
    end

    safety_assured do
      execute "CREATE SEQUENCE projects_project_nr_seq START 1"
      execute "ALTER TABLE projects ALTER COLUMN project_nr SET DEFAULT NEXTVAL('projects_project_nr_seq')"
    end
  end

  def self.down
    drop_table :projects

    execute "DROP SEQUENCE projects_project_nr_seq"
  end
end
