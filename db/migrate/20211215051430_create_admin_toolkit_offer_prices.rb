# frozen_string_literal: true

class CreateAdminToolkitOfferPrices < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :admin_toolkit_offer_prices, id: :uuid do |t|
      t.integer :min_apartments, null: false
      t.integer :max_apartments, null: false
      t.jsonb :name, default: {}
      t.decimal :value, null: false
      t.integer :index, default: 0, null: false, algorithm: :concurrently
      t.timestamps
    end
  end
end
