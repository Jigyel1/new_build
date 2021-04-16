# frozen_string_literal: true

class AddDiscardedAtToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :telco_uam_users, :discarded_at, :datetime
    add_index :telco_uam_users, :discarded_at
  end
end
