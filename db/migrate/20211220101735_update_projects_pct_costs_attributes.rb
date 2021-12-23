# frozen_string_literal: true

class UpdateProjectsPctCostsAttributes < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :projects_pct_costs, :build_cost, :decimal, precision: 15, scale: 2
      add_column :projects_pct_costs, :roi, :decimal, precision: 15, scale: 2

      remove_reference :projects_pct_costs, :project
      add_reference(
        :projects_pct_costs,
        :connection_cost,
        type: :uuid,
        foreign_key: { to_table: :projects_connection_costs }
      )
    end
  end
end
