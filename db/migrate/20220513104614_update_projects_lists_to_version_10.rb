# frozen_string_literal: true

class UpdateProjectsListsToVersion10 < ActiveRecord::Migration[6.1]
  def change
    update_view :projects_lists, version: 10, revert_to_version: 9, materialized: true
  end
end
