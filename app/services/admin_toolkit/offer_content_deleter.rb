# frozen_string_literal: true

module AdminToolkit
  class OfferContentDeleter < BaseService
    include OfferContentFinder

    def call
      authorize! offer_content, to: :destroy?, with: AdminToolkitPolicy

      offer_content.destroy!
    end

    # TODO: Implement activity log for this service in next PR
    private

    def activity_params
      {
        action: :offer_content_deleted,
        owner: current_user,
        trackable: offer_content,
        parameters: attributes
      }
    end
  end
end
