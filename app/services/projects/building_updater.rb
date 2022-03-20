# frozen_string_literal: true

module Projects
  class BuildingUpdater < BaseService
    include BuildingHelper
    include ProjectUpdaterHelper

    attr_accessor :project

    def call
      authorize! project, to: :update?

      with_tracking do
        building.update!(attributes)
        update_project_date(project.buildings, project)
      end
    end

    private

    def project
      @_project ||= building.project
    end

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
