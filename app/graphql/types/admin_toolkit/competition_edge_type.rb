# frozen_string_literal: true

module Types
  module AdminToolkit
    class CompetitionEdgeType < GraphQL::Types::Relay::BaseEdge
      node_type(Types::AdminToolkit::CompetitionType)
    end
  end
end
