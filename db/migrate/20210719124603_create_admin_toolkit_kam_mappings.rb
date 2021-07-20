# frozen_string_literal: true

class CreateAdminToolkitKamMappings < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_kam_mappings, id: :uuid do |t|
      t.references :kam, null: false, foreign_key: { to_table: :telco_uam_users }, type: :uuid
      t.string :investor_id, null: false, index: true, unique: true
      t.text :investor_description

      t.timestamps
    end
  end
end
