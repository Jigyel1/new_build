# frozen_string_literal: true

class CreateAdminToolkitOfferAdditionalCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_offer_additional_costs, id: :uuid do |t|
      t.jsonb :name, default: {}
      t.decimal :value, null: false
      t.string :additional_cost_type, default: :discount
      t.timestamps
    end
  end
end
