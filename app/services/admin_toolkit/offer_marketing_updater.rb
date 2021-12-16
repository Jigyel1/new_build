# frozen_string_literal: true

module AdminToolkit
  class OfferMarketingUpdater < BaseService
    include OfferMarketingFinder

    def call
      authorize! offer_marketing, to: :update?, with: AdminToolkitPolicy

      offer_marketing.update!(attributes)
    end

    # TODO: Implement activity log for this service in next PR
    private

    def activity_params
      {
        action: :offer_marketing_updated,
        owner: current_user,
        trackable: offer_marketing,
        parameters: attributes
      }
    end
  end
end
