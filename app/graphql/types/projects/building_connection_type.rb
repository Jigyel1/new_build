# frozen_string_literal: true

module Types
  module Projects
    class BuildingConnectionType < BaseConnectionType
      edge_type(Types::Projects::BuildingEdgeType)
    end
  end
end