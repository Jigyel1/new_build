# frozen_string_literal: true

module Projects
  class BuildingDeleter < BaseService
    include BuildingHelper
    include ProjectUpdaterHelper

    def call
      authorize! project, to: :update?

      with_tracking do
        building.destroy!
        update_project_date(project.buildings, project)
      end
    end

    private

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
