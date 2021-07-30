# frozen_string_literal: true

module Types
  class ActivityConnectionType < BaseConnectionType
    edge_type(Types::ActivityEdgeType)
  end
end
