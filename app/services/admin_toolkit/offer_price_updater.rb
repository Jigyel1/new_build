# frozen_string_literal: true

module AdminToolkit
  class OfferPriceUpdater < BaseService
    include OfferPriceFinder

    def call
      authorize! offer_price, to: :update?, with: AdminToolkitPolicy

      offer_price.assign_attributes(attributes)
      propagate_changes!
      offer_price.save!
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

    # Increments the min_apartment of the adjacent(but with higher index) record to record's max_apartment + 1
    # eg. Say Price A has a min_apartments 10, max 1000 and Price B has min_apartment 1001, max_apartment 3000
    #    And an update is triggered for Price A with max_apartment of 1501. This method should
    #   update Price's min_apartment to 1502.
    def propagate_changes! # rubocop:disable Metrics/AbcSize
      return unless offer_price.max_apartments_changed?

      target_offer_price = AdminToolkit::OfferPrice.find_by(index: offer_price.index + 1)
      return unless target_offer_price

      target_offer_price.update!(min_apartments: offer_price.max_apartments + 1)
    rescue ActiveRecord::RecordInvalid
      raise I18n.t(
        'admin_toolkit.offer_price.invalid_min',
        index: target_offer_price.index,
        new_max: offer_price.max_apartments + 1,
        old_max: target_offer_price.max_apartments
      )
    end
  end
end
