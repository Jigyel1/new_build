# frozen_string_literal: true

module AdminToolkit
  class OfferPriceUpdater < BaseService

    def call
      ::AdminToolkit::OfferPrice.find(attributes[:id]).update!(attributes)
    end

    # TODO: Implement activity log for this service in next PR
    private

    def activity_params
      {
        action: :offer_price_updated,
        owner: current_user,
        trackable: offer_content,
        parameters: attributes
      }
    end
  end
end