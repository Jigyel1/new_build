# frozen_string_literal: true

class UpdateUsersListsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :users_lists, version: 2, revert_to_version: 1, materialized: true
  end
end
