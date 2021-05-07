# frozen_string_literal: true

module Types
  class UserConnectionType < GraphQL::Types::Relay::BaseConnection
    edge_type(Types::UserEdgeType)

    field :total_count, Integer, null: false

    # - `object` is the Connection
    # - `object.items` is the original collection of Users
    def total_count
      object.items.size
    end
  end
end
