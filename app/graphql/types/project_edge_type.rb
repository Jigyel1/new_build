# frozen_string_literal: true

module Types
  class ProjectEdgeType < GraphQL::Types::Relay::BaseEdge
    node_type(Types::ProjectsListType)
  end
end
