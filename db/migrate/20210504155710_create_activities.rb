# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[6.1]
  def change
    create_table :activities, id: :uuid do |t|
      t.references :owner, type: :uuid, null: false, foreign_key: { to_table: :telco_uam_users }
      t.references :trackable, type: :uuid, polymorphic: true
      t.references :recipient, type: :uuid, null: false, foreign_key: { to_table: :telco_uam_users }
      t.string :action, null: false
      t.text :log_data, null: false, default: '', index: true

      t.timestamps
    end

    add_index :activities, %i[trackable_id trackable_type]
    add_index :activities, :created_at, order: :desc
  end
end
