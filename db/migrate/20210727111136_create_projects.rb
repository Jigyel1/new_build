class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects, id: :uuid do |t|
      t.string :name
      t.string :external_id
      t.string :project_nr
      t.string :type
      t.string :category
      t.string :landlord
      t.references :assignee, null: false, foreign_key: { to_table: :telco_uam_users }, type: :uuid
      t.string :construction_type
      t.date :move_in_from
      t.date :move_in_till
      t.string :lot_number
      t.integer :buildings
      t.integer :apartments

      t.timestamps
    end
  end
end
