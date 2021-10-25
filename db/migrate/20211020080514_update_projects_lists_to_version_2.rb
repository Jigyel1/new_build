# frozen_string_literal: true

class UpdateProjectsListsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :projects_lists, version: 2, revert_to_version: 1, materialized: true
  end
end
