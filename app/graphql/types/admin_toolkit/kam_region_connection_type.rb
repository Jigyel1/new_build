# frozen_string_literal: true

module Types
  module AdminToolkit
    class KamRegionConnectionType < BaseConnectionType
      edge_type(Types::AdminToolkit::KamRegionEdgeType)
    end
  end
end
