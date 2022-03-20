# frozen_string_literal: true

module Projects
  class BuildingCreator < BaseService
    include ProjectUpdaterHelper

    attr_reader :building

    def call
      authorize! project, to: :update?

      with_tracking do
        @building = project.buildings.create!(attributes)
        update_project_date(project.buildings, project)
      end
    end

    private

    def project
      @_project ||= Project.find(attributes[:project_id])
    end

    def activity_params
      {
        action: :building_created,
        owner: current_user,
        trackable: building,
        parameters: { name: building.name, project_name: building.project_name }
      }
    end
  end
end
