# frozen_string_literal: true

module Types
  class RoleConnectionType < GraphQL::Types::Relay::BaseConnection
    edge_type(Types::RoleEdgeType)

    field :total_count, Integer, null: false

    # - `object` is the Connection
    # - `object.items` is the original collection of Roles
    def total_count
      object.items.size
    end
  end
end
