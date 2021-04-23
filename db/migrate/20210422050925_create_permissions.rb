class CreatePermissions < ActiveRecord::Migration[6.1]
  def change
    create_table :permissions, id: :uuid do |t|
      t.string :resource, null: false
      t.jsonb :actions, null: false, default: {}, index: true
      t.references :accessor, polymorphic: true, type: :uuid

      t.timestamps
    end
  end
end

