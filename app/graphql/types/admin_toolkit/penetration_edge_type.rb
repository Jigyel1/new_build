# frozen_string_literal: true

module Types
  module AdminToolkit
    class PenetrationEdgeType < GraphQL::Types::Relay::BaseEdge
      node_type(Types::AdminToolkit::PenetrationType)
    end
  end
end
