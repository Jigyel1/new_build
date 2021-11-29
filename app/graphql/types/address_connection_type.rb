# frozen_string_literal: true

module Types
  class AddressConnectionType < BaseConnectionType
    edge_type(Types::AddressEdgeType)
  end
end
