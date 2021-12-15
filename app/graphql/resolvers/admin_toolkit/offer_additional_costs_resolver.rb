# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class OfferAdditionalCostsResolver < SearchObjectBase
      scope { ::AdminToolkit::OfferAdditionalCost.all }

      type [Types::AdminToolkit::OfferAdditionalCostType], null: false
    end
  end
end
