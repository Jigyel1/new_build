# frozen_string_literal: true

module Types
  module Projects
    class TaskConnectionType < BaseConnectionType
      edge_type(Types::Projects::TaskEdgeType)
    end
  end
end