# frozen_string_literal: true

class AddDiscardedAtToAddressBooks < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :projects_address_books, :discarded_at, :datetime
    add_index :projects_address_books, :discarded_at, algorithm: :concurrently
  end
end
