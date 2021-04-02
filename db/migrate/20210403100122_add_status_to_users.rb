class AddStatusToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :telco_uam_users, :active, :boolean, default: true
  end
end
