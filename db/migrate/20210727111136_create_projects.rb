# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[6.1]
  def self.up # rubocop:disable Metrics/SeliseMethodLength, Metrics/AbcSize
    create_table :projects, id: :uuid do |t|
      t.string :name
      t.string :external_id, index: { unique: :case_insensitive_comparison }
      t.string :internal_id
      t.string :project_nr
      t.string :priority
      t.string :category
      t.string :status, null: false, default: 'Open', index: true
      t.string :assignee_type, null: false, default: 'NBO Project'
      t.string :entry_type, null: false, default: 'Manual'

      t.references :assignee, foreign_key: { to_table: :telco_uam_users }, type: :uuid
      t.references :kam_region, foreign_key: { to_table: :admin_toolkit_kam_regions }, type: :uuid

      t.string :construction_type
      t.date :construction_starts_on
      t.date :move_in_starts_on
      t.date :move_in_ends_on
      t.string :lot_number
      t.integer :buildings_count, null: false, default: 0
      t.integer :apartments_count

      t.text :description
      t.text :additional_info
      t.float :coordinate_east
      t.float :coordinate_north
      t.string :label_list, null: false, default: [], array: true

      t.jsonb :additional_details, default: {}, index: true
      t.integer :address_books_count, null: false, default: 0
      t.integer :files_count, null: false, default: 0
      t.integer :tasks_count, null: false, default: 0 # excludes archived ones
      t.integer :completed_tasks_count, null: false, default: 0

      t.boolean :standard_cost_applicable
      t.string :access_technology
      t.boolean :in_house_installation

      t.timestamps
    end

    safety_assured do
      execute 'CREATE SEQUENCE projects_project_nr_seq START 1'
      execute "ALTER TABLE projects ALTER COLUMN project_nr SET DEFAULT NEXTVAL('projects_project_nr_seq')"
    end
  end

  def self.down
    drop_table :projects

    execute 'DROP SEQUENCE projects_project_nr_seq'
  end
end
