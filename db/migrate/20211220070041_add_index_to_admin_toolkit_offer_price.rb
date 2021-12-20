# frozen_string_literal: true

class AddIndexToAdminToolkitOfferPrice < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :admin_toolkit_offer_prices, :index, :string
    add_index :admin_toolkit_offer_prices, :index, unique: true, algorithm: :concurrently
  end
end
