# frozen_string_literal: true

module AdminToolkit
  class OfferAdditionalCostCreator < BaseService
    attr_reader :offer_additional_cost

    def call
      @offer_additional_cost = ::AdminToolkit::OfferAdditionalCost.create!(attributes)
    end

    # TODO: Implement activity log for this service in next PR
    private

    def activity_params
      {
        action: :offer_additional_cost_created,
        owner: current_user,
        trackable: offer_additional_cost,
        parameters: attributes
      }
    end
  end
end
