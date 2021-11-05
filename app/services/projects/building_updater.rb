# frozen_string_literal: true

module Projects
  class BuildingUpdater < BaseService
    include BuildingHelper

    def call
      authorize! building.project, to: :update?

      with_tracking { building.update!(attributes) }
    end

    private

    def activity_params
      {
        action: :building_updated,
        owner: current_user,
        trackable: building,
        parameters: { name: building.name, project_name: building.project_name }
      }
    end
  end
end
