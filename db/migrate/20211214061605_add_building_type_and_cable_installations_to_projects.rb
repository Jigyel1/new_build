# frozen_string_literal: true

class AddBuildingTypeAndCableInstallationsToProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :projects, bulk: true do |t|
        t.string :building_type
        t.text :cable_installations, array: true, default: []
      end
    end
  end
end
