# frozen_string_literal: true

module Types
  module AdminToolkit
    class OfferAdditionalCostType < BaseObject
      field :id, ID, null: true
      field :name, GraphQL::Types::JSON, null: true
      field :value, Float, null: true
      field :additional_cost_type, String, null: true
    end
  end
end
