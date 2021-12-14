# frozen_string_literal: true

class CreateAdminToolkitOfferPositions < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_offer_positions, id: :uuid do |t|
      t.jsonb :added_costs, default: {}
      t.decimal :cost, null: false
      t.timestamps
    end
  end
end
