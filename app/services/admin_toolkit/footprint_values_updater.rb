# frozen_string_literal: true

module AdminToolkit
  class FootprintValuesUpdater < BaseService
    private

    def process
      authorize! ::AdminToolkit::FootprintValue, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        attributes.each do |hash|
          ::AdminToolkit::FootprintValue.find(hash.delete(:id)).update!(hash)
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
