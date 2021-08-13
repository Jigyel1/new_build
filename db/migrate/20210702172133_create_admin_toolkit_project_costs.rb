# frozen_string_literal: true

class CreateAdminToolkitProjectCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_project_costs, id: :uuid do |t|
      t.decimal :standard, precision: 15, scale: 2
      t.decimal :arpu, precision: 15, scale: 2
      t.decimal :socket_installation_rate, precision: 15, scale: 2
      t.integer :index, default: 0, null: false

      t.timestamps
    end
  end
end
