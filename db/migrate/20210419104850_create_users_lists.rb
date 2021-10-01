# frozen_string_literal: true

class CreateUsersLists < ActiveRecord::Migration[6.1]
  def change
    create_view :users_lists, materialized: true
  end
end
