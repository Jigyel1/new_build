# frozen_string_literal: true

module Types
  class ActivityConnectionType < GraphQL::Types::Relay::BaseConnection
    edge_type(Types::ActivityEdgeType)

    field :total_count, Integer, null: false

    # - `object` is the Connection
    # - `object.items` is the original collection of activities
    def total_count
      object.items.size
    end
  end
end
