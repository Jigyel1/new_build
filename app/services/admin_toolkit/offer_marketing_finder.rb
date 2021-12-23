# frozen_string_literal: true

module AdminToolkit
  module OfferMarketingFinder
    def offer_marketing
      @offer_marketing ||= AdminToolkit::OfferMarketing.find(attributes[:id])
    end
  end
end
