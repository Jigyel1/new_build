# frozen_string_literal: true

class AddIdsToActivities < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_column :activities, :project_id, :string, null: true
      add_column :activities, :os_id, :string, null: true
    end
  end
end
