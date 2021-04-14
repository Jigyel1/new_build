# frozen_string_literal: true

# This migration comes from telco_uam (originally 20210317072101)

class AddJtiToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :telco_uam_users, :jti, :string

    Telco::Uam::User.all.each { |user| user.update_column(:jti, SecureRandom.uuid) }
  end

  change_column_null :telco_uam_users, :jti, false
  add_index :telco_uam_users, :jti, unique: true
end
