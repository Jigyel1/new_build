# frozen_string_literal: true

module Types
  module AdminToolkit
    class KamMappingEdgeType < GraphQL::Types::Relay::BaseEdge
      node_type(Types::AdminToolkit::KamMappingType)
    end
  end
end
