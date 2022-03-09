# frozen_string_literal: true

class UpdateProjectsPctCosts < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :projects_pct_costs, :payback_period, :integer
      add_column :projects_pct_costs, :payback_period, :float
    end
  end
end
