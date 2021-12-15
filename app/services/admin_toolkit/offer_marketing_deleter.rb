# frozen_string_literal: true

module AdminToolkit
  class OfferMarketingDeleter < BaseService
    include OfferMarketingFinder

    def call
      offer_marketing.destroy!
    end

    # TODO: Implement activity log for this service in next PR
    private

    def activity_params
      {
        action: :offer_marketing_deleted,
        owner: current_user,
        trackable: offer_marketing,
        parameters: attributes
      }
    end
  end
end
