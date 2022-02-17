# frozen_string_literal: true

class AddNewColumnToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :exceeding_cost, :decimal
  end
end
