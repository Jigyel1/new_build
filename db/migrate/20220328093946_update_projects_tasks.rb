# frozen_string_literal: true

class UpdateProjectsTasks < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :projects_tasks, bulk: true do |t|
        t.string :project_id, null: true
        t.string :building_id, null: true
        t.string :project_name, null: true
        t.string :host_url, null: true
      end
    end
  end
end
