# frozen_string_literal: true

# This migration comes from telco_uam

class ReAddJtiToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :telco_uam_users, :jti, :string

    Telco::Uam::User.all.each { |user| user.update_column(:jti, SecureRandom.uuid) }

    safety_assured do
      change_column_null :telco_uam_users, :jti, false
      add_index :telco_uam_users, :jti, unique: true
    end
  end
end
