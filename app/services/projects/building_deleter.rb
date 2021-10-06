# frozen_string_literal: true

module Projects
  class BuildingDeleter < BaseService
    include BuildingHelper

    def call
      authorize! building.project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        building.destroy!
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :building_deleted,
        owner: current_user,
        trackable: building,
        parameters: attributes
      }
    end
  end
end
