# frozen_string_literal: true

class AddFieldsToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :telco_uam_users, :role, type: :uuid, null: false, default: :kam, index: { algorithm: :concurrently }

    safety_assured do
      change_table :telco_uam_users, bulk: true do |t|
        t.boolean :active, null: false
      end
    end

    change_column_default :telco_uam_users, :active, from: nil, to: true
  end
end
