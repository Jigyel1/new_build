# frozen_string_literal: true

module AdminToolkit
  class OfferPriceUpdater < BaseService
    include OfferPriceFinder

    def call
      authorize! offer_price, to: :update?, with: AdminToolkitPolicy

      offer_price.update!(attributes)
    end

    # TODO: Implement activity log for this service in next PR
    private

    def activity_params
      {
        action: :offer_price_updated,
        owner: current_user,
        trackable: offer_price,
        parameters: attributes
      }
    end
  end
end
