# frozen_string_literal: true

module Types
  module AdminToolkit
    class PenetrationConnectionType < BaseConnectionType
      edge_type(Types::AdminToolkit::PenetrationEdgeType)
    end
  end
end
