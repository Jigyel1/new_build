# frozen_string_literal: true

class AddDiscardedAtToProjects < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :projects, :discarded_at, :datetime
    add_index :projects, :discarded_at, algorithm: :concurrently
  end
end
