# frozen_string_literal: true

# This migration comes from telco_uam (originally 20210520062248)
class AddOmniauthToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :telco_uam_users, bulk: true do |t|
      t.string :provider
      t.string :uid
    end
  end
end
