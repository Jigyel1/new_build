# This migration comes from telco_uam (originally 20210520062248)
class AddOmniauthToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :telco_uam_users, :provider, :string
    add_column :telco_uam_users, :uid, :string
  end
end
