# frozen_string_literal: true

# This migration comes from telco_uam (originally 20210527121006)
class RemoveJtiFromUsers < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :telco_uam_users, :jti, :string }
  end
end
