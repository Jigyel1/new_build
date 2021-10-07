# frozen_string_literal: true

module Projects
  class BuildingCreator < BaseService
    attr_reader :building

    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        @building = project.buildings.create!(attributes)
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def project
      @_project ||= Project.find(attributes[:project_id])
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :building_created,
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
