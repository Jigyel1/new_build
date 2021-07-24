# frozen_string_literal: true

module AdminToolkit
  class FootprintBuildingUpdater < BaseService
    def footprint_building
      @footprint_building ||= AdminToolkit::FootprintBuilding.find(attributes[:id])
    end

    def call
      authorize! footprint_building, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        ::AdminToolkit::FootprintBuilding.transaction do
          footprint_building.assign_attributes(attributes)
          propagate_changes!
          footprint_building.save!
        end

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def propagate_changes! # rubocop:disable Metrics/AbcSize
      return unless footprint_building.max_changed?

      target_footprint_building = AdminToolkit::FootprintBuilding.find_by(index: footprint_building.index + 1)
      return unless target_footprint_building

      target_footprint_building.update!(min: footprint_building.max + 1)
    rescue ActiveRecord::RecordInvalid
      raise I18n.t(
        'admin_toolkit.footprint_building.invalid_min',
        index: target_footprint_building.index,
        new_max: footprint_building.max + 1,
        old_max: target_footprint_building.max
      )
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :footprint_building_updated,
        owner: current_user,
        trackable: footprint_building,
        parameters: attributes.except(:id)
      }
    end
  end
end
