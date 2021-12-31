# frozen_string_literal: true

class RemoveStandardCostApplicableFromProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :projects, :standard_cost_applicable, :boolean
    end
  end
end
