# frozen_string_literal: true

module Types
  module Projects
    class TaskEdgeType < GraphQL::Types::Relay::BaseEdge
      node_type(Types::Projects::TaskType)
    end
  end
end
