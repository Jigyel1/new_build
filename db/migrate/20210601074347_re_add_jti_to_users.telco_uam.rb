# frozen_string_literal: true

# This migration comes from telco_uam

class ReAddJtiToUsers < ActiveRecord::Migration[6.1]
  class User < ApplicationRecord # This makes the migration reversible.
    self.table_name = 'telco_uam_users'
  end

  def change
    add_column :telco_uam_users, :jti, :string
    User.find_each { |user| user.update_column(:jti, SecureRandom.uuid) }

    safety_assured do
      change_column_null :telco_uam_users, :jti, false
      add_index :telco_uam_users, :jti, unique: true
    end
  end
end
