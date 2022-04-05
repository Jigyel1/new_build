# frozen_string_literal: true

class AddKamAssigneeNameToProjects < ActiveRecord::Migration[6.1]
  def change
    add_column :projects, :kam_assignee_name, :string
  end
end
