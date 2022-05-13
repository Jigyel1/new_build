# frozen_string_literal: true

class RemoveKamAssigneeNameFromProjects < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :projects, :kam_assignee_name, :string }
  end
end
