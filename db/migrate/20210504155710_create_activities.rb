class CreateActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :activities, id: :uuid do |t|
      t.references :owner, type: :uuid, null: false, foreign_key: { to_table: :telco_uam_users }
      t.references :trackable, type: :uuid, polymorphic: true
      t.references :recipient, type: :uuid, null: false, foreign_key: { to_table: :telco_uam_users }
      t.string :verb, null: false

      t.jsonb :parameters, null: false, default: {}, index: true

      t.timestamps
    end

    add_index :activities, [:trackable_id, :trackable_type]
  end
end
