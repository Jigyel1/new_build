# frozen_string_literal: true

module Types
  module AdminToolkit
    class KamRegionEdgeType < GraphQL::Types::Relay::BaseEdge
      node_type(Types::AdminToolkit::KamRegionType)
    end
  end
end
