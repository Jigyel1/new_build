# frozen_string_literal: true

module AdminToolkit
  class OfferContentUpdater < BaseService
    include OfferContentFinder

    def call
      offer_content.update!(attributes)
    end

    # TODO: Implement activity log for this service in next PR
    private

    def activity_params
      {
        action: :offer_content_updated,
        owner: current_user,
        trackable: offer_content,
        parameters: attributes
      }
    end
  end
end
