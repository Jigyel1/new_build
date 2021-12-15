# frozen_string_literal: true

module AdminToolkit
  class OfferAdditionalCostDeleter < BaseService
    include OfferAdditionalCostFinder

    def call
      offer_additional_cost.destroy!
    end

    # TODO: Implement activity log for this service in next PR
    private

    def activity_params
      {
        action: :offer_additional_cost_deleted,
        owner: current_user,
        trackable: offer_additional_cost,
        parameters: attributes
      }
    end
  end
end
