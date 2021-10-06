# frozen_string_literal: true

class CreateProjectsPctCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :projects_pct_costs, id: :uuid do |t|
      t.decimal :project_cost, precision: 15, scale: 2
      t.decimal :socket_installation_cost, precision: 15, scale: 2, default: 0
      t.decimal :project_connection_cost, precision: 15, scale: 2
      t.decimal :arpu, precision: 15, scale: 2
      t.decimal :lease_cost, precision: 15, scale: 2

      t.float :penetration_rate
      t.integer :payback_period, default: 0, null: false # in months
      t.boolean :system_generated_payback_period, default: true, null: false
      t.references :project, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
