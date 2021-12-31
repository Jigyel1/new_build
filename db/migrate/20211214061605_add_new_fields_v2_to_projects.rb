# frozen_string_literal: true

class AddNewFieldsV2ToProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :projects, bulk: true do |t|
        t.string :building_type
        t.text :cable_installations, array: true, default: []
        t.string :priority_tac
        t.string :access_technology_tac
      end
    end
  end
end
