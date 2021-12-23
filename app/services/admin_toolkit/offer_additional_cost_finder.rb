# frozen_string_literal: true

module AdminToolkit
  module OfferAdditionalCostFinder
    def offer_additional_cost
      @offer_additional_cost ||= AdminToolkit::OfferAdditionalCost.find(attributes[:id])
    end
  end
end
