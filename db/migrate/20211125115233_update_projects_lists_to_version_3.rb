# frozen_string_literal: true

class UpdateProjectsListsToVersion3 < ActiveRecord::Migration[6.1]
  def change
    update_view :projects_lists, version: 3, revert_to_version: 2, materialized: true
  end
end
