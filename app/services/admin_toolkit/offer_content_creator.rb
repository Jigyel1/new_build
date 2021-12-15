# frozen_string_literal: true

module AdminToolkit
  class OfferContentCreator < BaseService
    attr_reader :offer_content

    def call
      @offer_content = ::AdminToolkit::OfferContent.create!(attributes)
    end

    # TODO: Implement activity log for this service in next PR
    private

    def activity_params
      {
        action: :offer_content_created,
        owner: current_user,
        trackable: offer_content,
        parameters: attributes
      }
    end
  end
end
