# frozen_string_literal: true

class AddJobIdsToProjectsTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :projects_tasks, :job_ids, :string, array: true
  end
end
