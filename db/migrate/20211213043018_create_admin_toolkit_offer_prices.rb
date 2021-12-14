# frozen_string_literal: true

class CreateAdminToolkitOfferPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_offer_prices, id: :uuid do |t|
      t.integer :min, null: false
      t.integer :max, null: false
      t.jsonb :name, default: {}
      t.decimal :price, null: false

      t.timestamps
    end
  end
end
