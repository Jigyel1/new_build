# frozen_string_literal: true

module Types
  class UserEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::UsersType)
  end
end
