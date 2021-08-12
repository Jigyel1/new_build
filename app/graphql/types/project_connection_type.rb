# frozen_string_literal: true

module Types
  class ProjectConnectionType < BaseConnectionType
    edge_type(Types::ProjectEdgeType)
  end
end
