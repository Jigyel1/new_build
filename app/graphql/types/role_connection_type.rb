# frozen_string_literal: true

module Types
  class RoleConnectionType < BaseConnectionType
    edge_type(Types::RoleEdgeType)
  end
end
