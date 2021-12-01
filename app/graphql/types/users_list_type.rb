# frozen_string_literal: true

module Types
  class UsersListType < BaseObject
    field :id, ID, null: true
    field :name, String, null: true
    field :email, String, null: true
    field :active, Boolean, null: true
    field :role, String, null: true
    field :permissions, [Types::PermissionType], null: true
    field :phone, String, null: true
    field :department, String, null: true
    field :avatar_url, String, null: true

    def permissions
      User.find(object.id).permissions
    end
  end
end
