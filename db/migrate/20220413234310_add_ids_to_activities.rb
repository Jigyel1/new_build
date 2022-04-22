# frozen_string_literal: true

class AddIdsToActivities < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :activities, bulk: true do |t|
        t.string :project_id, null: true
        t.string :project_external_id, null: true
        t.string :os_id, null: true
      end
    end
  end
end
