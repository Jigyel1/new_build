# frozen_string_literal: true

module Types
  class RoleType < BaseObject
    USERS_PER_ROLE = ENV['USERS_PER_ROLE'] ? ENV['USERS_PER_ROLE'].to_i : 10

    field :id, ID, null: false
    field :name, String, null: true
    field :users_count, Integer, null: true

    field :permissions, [Types::PermissionType], null: true

    field :users, [Types::UsersListType], null: true, description: <<~DESC
      Get the first N(as set in the ENV or 10) users' avatar_url with names for each role.
    DESC

    def users
      BatchLoaders::WindowKeyLoader
        .for(
          UsersList,
          :role_id,
          limit: USERS_PER_ROLE,
          order_col: :avatar_url,
          order_dir: :asc
        )
        .load(object.id)
    end
  end
end
