# frozen_string_literal: true

module Projects
  class BuildingUpdater < BaseService
    attr_reader :building

    def call
      authorize! building.project, to: :update?, with: ProjectPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        building.update!(attributes)
        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def building
      @_building ||= Projects::Building.find(attributes.delete(:id))
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :building_updated,
        owner: current_user,
        trackable: building,
        parameters: attributes
      }
    end
  end
end
