class UpdateProjectsListsToVersion5 < ActiveRecord::Migration[6.1]
  def change
    update_view :projects_lists, version: 5, revert_to_version: 4, materialized: true
  end
end
