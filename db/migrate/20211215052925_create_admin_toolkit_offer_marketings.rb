# frozen_string_literal: true

class CreateAdminToolkitOfferMarketings < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_offer_marketings, id: :uuid do |t|
      t.jsonb :activity_name, default: {}
      t.decimal :value, null: false
      t.timestamps
    end
  end
end
