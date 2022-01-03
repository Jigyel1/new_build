# frozen_string_literal: true

class CreateAdminToolkitCostThreshold < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_cost_thresholds, id: :uuid do |t|
      t.decimal :not_exceeding
      t.decimal :exceeding
      t.timestamps
    end
  end
end
