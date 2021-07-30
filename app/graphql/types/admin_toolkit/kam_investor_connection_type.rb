# frozen_string_literal: true

module Types
  module AdminToolkit
    class KamInvestorConnectionType < BaseConnectionType
      edge_type(Types::AdminToolkit::KamInvestorEdgeType)
    end
  end
end
