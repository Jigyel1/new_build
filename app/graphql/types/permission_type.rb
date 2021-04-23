# frozen_string_literal: true

module Types
  class PermissionType < BaseObject
    field :id, type: ID, null: true
    field :resource, type: String, null: true
    field :actions, type: GraphQL::Types::JSON, null: true
    field :accessor_id, type: ID, null: true
    field :accessor_type, type: String, null: true
  end
end
