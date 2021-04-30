# frozen_string_literal: true

module Types
  class PermissionType < BaseObject
    field :id, type: ID, null: true
    field :resource, type: String, null: true
    field :actions, type: GraphQL::Types::JSON, null: true

    field :accessor_id, type: ID, null: true, description: <<~DESC
      ID of the user if the permission is for a user, role otherwise.
    DESC

    field :accessor_type, type: String, null: true, description: <<~DESC
      User if the permission is for a user, Role otherwise.
    DESC
  end
end
