class CreateProjectsBuildings < ActiveRecord::Migration[6.1]
  def change
    create_table :projects_buildings, id: :uuid do |t|
      t.string :name, null: false
      t.string :external_id, null: true, index: true

      t.references :assignee, null: true, foreign_key: { to_table: :telco_uam_users }, type: :uuid
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.integer :apartments_count, null: false, default: 0
      t.date :move_in_starts_on
      t.date :move_in_ends_on

      t.timestamps
    end
  end
end
