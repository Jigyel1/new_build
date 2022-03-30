class UpdateProjectsListsToVersion7 < ActiveRecord::Migration[6.1]
  def change
    update_view :projects_lists, version: 7, revert_to_version: 6, materialized: true
  end
end
