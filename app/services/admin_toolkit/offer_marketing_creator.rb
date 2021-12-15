# frozen_string_literal: true

module AdminToolkit
  class OfferMarketingCreator < BaseService
    attr_reader :offer_marketing

    def call
      @offer_marketing = ::AdminToolkit::OfferMarketing.create!(attributes)
    end

    # TODO: Implement activity log for this service in next PR
    private

    def activity_params
      {
        action: :offer_marketing_created,
        owner: current_user,
        trackable: offer_marketing,
        parameters: attributes
      }
    end
  end
end
