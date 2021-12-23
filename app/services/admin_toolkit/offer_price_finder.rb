# frozen_string_literal: true

module AdminToolkit
  module OfferPriceFinder
    def offer_price
      @offer_price ||= AdminToolkit::OfferPrice.find(attributes[:id])
    end
  end
end
