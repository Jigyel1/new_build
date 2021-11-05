# frozen_string_literal: true

module Projects
  class BuildingDeleter < BaseService
    include BuildingHelper

    def call
      authorize! building.project, to: :update?

      with_tracking { building.destroy! }
    end

    def activity_params
      {
        action: :building_deleted,
        owner: current_user,
        trackable: building,
        parameters: { name: building.name, project_name: building.project_name }
      }
    end
  end
end
