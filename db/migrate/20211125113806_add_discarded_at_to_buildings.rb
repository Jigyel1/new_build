# frozen_string_literal: true

class AddDiscardedAtToBuildings < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :projects_buildings, :discarded_at, :datetime
    add_index :projects_buildings, :discarded_at, algorithm: :concurrently
  end
end
