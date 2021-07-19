class CreateAdminToolkitPenetrations < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_penetrations, id: :uuid do |t|
      t.string :zip, null: false, index: true, unique: true
      t.string :city, null: false
      t.float :rate, null: false
      t.string :competition, null: false
      t.string :kam_region, null: false
      t.boolean :hfc_footprint, null: false
      t.string :type, null: false

      t.timestamps
    end
  end
end
