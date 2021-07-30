# frozen_string_literal: true

module Types
  module AdminToolkit
    class CompetitionConnectionType < BaseConnectionType
      edge_type(Types::AdminToolkit::CompetitionEdgeType)
    end
  end
end
