# frozen_string_literal: true

module Types
  module Projects
    class BuildingEdgeType < GraphQL::Types::Relay::BaseEdge
      node_type(Types::Projects::BuildingType)
    end
  end
end
