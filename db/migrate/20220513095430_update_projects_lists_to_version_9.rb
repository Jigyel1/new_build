class UpdateProjectsListsToVersion9 < ActiveRecord::Migration[6.1]
  def change
    update_view :projects_lists, version: 9, revert_to_version: 8, materialized: true
  end
end
