# frozen_string_literal: true

module AdminToolkit
  class PctValuesUpdater < BaseService
    private

    def process
      authorize! ::AdminToolkit::PctValue, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        attributes.each do |hash|
          ::AdminToolkit::PctValue.find(hash[:id]).update!(hash)
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
        action: :pct_value_updated,
        owner: current_user,
        trackable: ::AdminToolkit::PctValue.find(attributes.dig(0, :id)),
        parameters: attributes
      }
    end
  end
end
