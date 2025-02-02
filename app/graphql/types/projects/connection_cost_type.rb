# frozen_string_literal: true

module Types
  module Projects
    class ConnectionCostType < BaseObject
      field :id, ID, null: true
      field :connection_type, String, null: true
      field :cost_type, String, null: true
      field :pct_cost, Types::Projects::PctCostType, null: true
    end
  end
end
