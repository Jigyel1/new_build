# frozen_string_literal: true

module Types
  class RoleEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::RoleType)
  end
end
