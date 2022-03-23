class UpdateProjectsListsToVersion6 < ActiveRecord::Migration[6.1]
  def change
    update_view :projects_lists, version: 6, revert_to_version: 5, materialized: true
  end
end
