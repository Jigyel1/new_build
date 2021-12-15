# frozen_string_literal: true

module Types
  module Projects
    class ConnectionCostType < BaseObject
      field :id, ID, null: true
      field :connection_type, String, null: true
      field :standard_cost, Boolean, null: true
      field :cost, Float, null: true
      field :too_expensive, Boolean, null: true
    end
  end
end
