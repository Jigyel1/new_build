# frozen_string_literal: true

module Types
  class AddressEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::AddressType)
  end
end
