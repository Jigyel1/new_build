# frozen_string_literal: true

module Types
  module AdminToolkit
    class OfferMarketingType < BaseObject
      field :activity_name, GraphQL::Types::JSON, null: true
      field :value, Float, null: true
    end
  end
end
