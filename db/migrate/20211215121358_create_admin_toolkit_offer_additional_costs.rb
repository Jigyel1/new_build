class CreateAdminToolkitOfferAdditionalCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_offer_additional_costs, id: :uuid do |t|
      t.jsonb :name, default: {}
      t.decimal :value, null: false
      t.string :type, default: 0
      t.timestamps
    end
  end
end
