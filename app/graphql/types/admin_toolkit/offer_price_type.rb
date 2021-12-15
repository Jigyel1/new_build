# frozen_string_literal: true

module Types
  module AdminToolkit
    class OfferPriceType < BaseObject
      field :min_apartments, Integer, null: true
      field :max_apartments, Integer, null: true
      field :name, GraphQL::Types::JSON, null: true
      field :value, Float, null: true
    end
  end
end
