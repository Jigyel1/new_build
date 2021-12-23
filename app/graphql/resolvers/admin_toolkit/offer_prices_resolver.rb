# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class OfferPricesResolver < SearchObjectBase
      scope { ::AdminToolkit::OfferPrice.all }

      type [Types::AdminToolkit::OfferPriceType], null: false
    end
  end
end
