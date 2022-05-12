# frozen_string_literal: true

class RemoveAssigneeIdFromBuildings < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :projects_buildings, :assignee_id, :uuid }
  end
end
