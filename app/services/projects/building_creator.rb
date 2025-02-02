# frozen_string_literal: true

module Projects
  class BuildingCreator < BaseService
    attr_reader :building

    def call
      authorize! project, to: :update?

      with_tracking { @building = project.buildings.create!(attributes) }
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
