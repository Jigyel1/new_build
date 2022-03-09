# frozen_string_literal: true

class AddNewColumnToProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :projects, :exceeding_cost, :decimal
    end
  end
end
