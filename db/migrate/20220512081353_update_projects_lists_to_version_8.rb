# frozen_string_literal: true

class UpdateProjectsListsToVersion8 < ActiveRecord::Migration[6.1]
  def change
    update_view :projects_lists, version: 8, revert_to_version: 7, materialized: true
  end
end
