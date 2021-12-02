class UpdateProjectsListsToVersion4 < ActiveRecord::Migration[6.1]
  def change
    update_view :projects_lists, version: 4, revert_to_version: 3, materialized: true
  end
end
