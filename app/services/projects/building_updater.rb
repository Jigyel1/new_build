# frozen_string_literal: true

module Projects
  class BuildingUpdater < BaseService
    include BuildingHelper

    def call
      authorize! building.project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        building.update!(attributes)
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :building_updated,
        owner: current_user,
        trackable: building,
        parameters: {
          name: building.name,
          project_name: building.project.name
        }
      }
    end
  end
end
