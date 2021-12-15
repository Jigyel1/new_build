# frozen_string_literal: true

module AdminToolkit
  module OfferContentFinder
    def offer_content
      @offer_content ||= AdminToolkit::OfferContent.find(attributes[:id])
    end
  end
end
