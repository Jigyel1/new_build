# frozen_string_literal: true

module Types
  module AdminToolkit
    class KamMappingConnectionType < BaseConnectionType
      edge_type(Types::AdminToolkit::KamMappingEdgeType)
    end
  end
end
