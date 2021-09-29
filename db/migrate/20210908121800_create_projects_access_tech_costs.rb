# frozen_string_literal: true

class CreateProjectsAccessTechCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :projects_access_tech_costs, id: :uuid do |t|
      t.decimal :hfc_on_premise_cost, precision: 15, scale: 2, null: false
      t.decimal :hfc_off_premise_cost, precision: 15, scale: 2, null: false
      t.decimal :lwl_on_premise_cost, precision: 15, scale: 2, null: false
      t.decimal :lwl_off_premise_cost, precision: 15, scale: 2, null: false

      t.text :comment
      t.text :explanation

      t.references :project, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
