# frozen_string_literal: true

class AddFieldsToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :telco_uam_users, :active, :boolean, default: true, null: false
    add_reference :telco_uam_users, :role, null: false, default: :kam, index: {algorithm: :concurrently}
  end
end
