# frozen_string_literal: true

class AddFieldsToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :telco_uam_users, :role, null: false, default: :kam, index: { algorithm: :concurrently }

    safety_assured do
      change_table :telco_uam_users, bulk: true do |t|
        t.boolean :active, null: false
      end
    end

    change_column_default :telco_uam_users, :active, from: nil, to: true

    add_column :telco_uam_users, :name, :string, null: false
    add_index :telco_uam_users, :name, algorithm: :concurrently
  end
end
