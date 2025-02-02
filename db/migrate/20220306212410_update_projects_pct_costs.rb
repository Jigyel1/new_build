# frozen_string_literal: true

class UpdateProjectsPctCosts < ActiveRecord::Migration[6.1]
  def up
    safety_assured { change_column :projects_pct_costs, :payback_period, :float }
  end

  def down
    change_column :projects_pct_costs, :payback_period, :integer
  end
end
