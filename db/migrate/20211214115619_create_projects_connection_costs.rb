# frozen_string_literal: true

class CreateProjectsConnectionCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :projects_connection_costs, id: :uuid do |t|
      t.string :connection_type, null: false
      t.string :cost_type, null: false
      t.references :project, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
