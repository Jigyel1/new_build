# frozen_string_literal: true

class CreateAdminToolkitProjectCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_toolkit_project_costs, id: :uuid do |t|
      t.decimal :standard
      t.decimal :arpu

      t.timestamps
    end
  end
end
