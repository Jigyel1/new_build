# frozen_string_literal: true

class UpdateProjectsBuildings < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      change_column :projects_buildings, :name, :string, null: true
      remove_column :projects_buildings, :move_in_ends_on, :date
    end
  end

  def down
    change_column :projects_buildings, :name, :string, null: false
  end
end
