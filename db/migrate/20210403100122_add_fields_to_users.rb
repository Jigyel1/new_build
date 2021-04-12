# frozen_string_literal: true

class AddFieldsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :telco_uam_users, :active, :boolean, default: true
    add_reference :telco_uam_users, :role, null: false, default: :kam, foreign_key: true
  end
end
