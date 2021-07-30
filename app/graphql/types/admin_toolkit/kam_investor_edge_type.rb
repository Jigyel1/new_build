# frozen_string_literal: true

module Types
  module AdminToolkit
    class KamInvestorEdgeType < GraphQL::Types::Relay::BaseEdge
      node_type(Types::AdminToolkit::KamInvestorType)
    end
  end
end
