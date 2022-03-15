# frozen_string_literal: true

class UpdateNameFromProjectsBuildings < ActiveRecord::Migration[6.1]
  def up
    change_column :projects_buildings, :name, :string, null: true
  end

  def down
    change_column :projects_buildings, :name, :string, null: false
  end
end
