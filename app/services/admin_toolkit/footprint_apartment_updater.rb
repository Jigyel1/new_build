# frozen_string_literal: true

module AdminToolkit
  class FootprintApartmentUpdater < BaseService
    def footprint_apartment
      @footprint_apartment ||= AdminToolkit::FootprintApartment.find(attributes[:id])
    end

    def call
      authorize! footprint_apartment, to: :update?, with: AdminToolkitPolicy

      with_tracking(transaction: true) do
        footprint_apartment.assign_attributes(attributes)
        propagate_changes!
        footprint_apartment.save!
      end
    end

    private

    # Increments the min of the adjacent(but with higher index) record to record's max + 1
    # eg. Say FootprintApartment(FPB) A has a min 1, max 10 and FPB B has min 11, max 30
    #    And an update is triggered for FPB A with max of 15. This method should
    #   update FPB's min to 16.
    def propagate_changes! # rubocop:disable Metrics/AbcSize
      return unless footprint_apartment.max_changed?

      target_footprint_apartment = AdminToolkit::FootprintApartment.find_by(index: footprint_apartment.index + 1)
      return unless target_footprint_apartment

      target_footprint_apartment.update!(min: footprint_apartment.max + 1)
    rescue ActiveRecord::RecordInvalid
      raise I18n.t(
        'admin_toolkit.footprint_apartment.invalid_min',
        index: target_footprint_apartment.index,
        new_max: footprint_apartment.max + 1,
        old_max: target_footprint_apartment.max
      )
    end

    def activity_params
      {
        action: :footprint_apartment_updated,
        owner: current_user,
        trackable: footprint_apartment,
        parameters: attributes.except(:id)
      }
    end
  end
end
