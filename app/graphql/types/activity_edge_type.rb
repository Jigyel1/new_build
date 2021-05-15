# frozen_string_literal: true

module Types
  class ActivityEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::ActivityType)
  end
end
