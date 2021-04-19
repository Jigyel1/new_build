# frozen_string_literal: true

module Types
  class RoleConnectionWithTotalCountType < GraphQL::Types::Relay::BaseConnection
    edge_type(Types::RoleEdgeType)

    field :total_count, Integer, null: false

    def total_count
      # - `object` is the Connection
      # - `object.items` is the original collection of Posts
      object.items.size
    end
  end
end
