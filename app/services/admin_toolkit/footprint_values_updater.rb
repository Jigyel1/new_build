# frozen_string_literal: true

module AdminToolkit
  class FootprintValuesUpdater < BaseService
    private

    def process
      authorize! ::AdminToolkit::FootprintValue, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        attributes.each do |footprint_value|
          id, project_type = footprint_value
          ::AdminToolkit::FootprintValue.find(id).update_column(:project_type, project_type)
        end

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def execute?
      true
    end


    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :footprint_values_updated,
        owner: current_user,
        trackable_type: 'AdminToolkit',
        parameters: attributes
      }
    end
  end
end
