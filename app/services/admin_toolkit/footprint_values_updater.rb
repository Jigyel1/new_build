# frozen_string_literal: true

module AdminToolkit
  class FootprintValuesUpdater < BaseService
    def call
      authorize! ::AdminToolkit::FootprintValue, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid, transaction: true) do
        attributes.each { |hash| ::AdminToolkit::FootprintValue.find(hash[:id]).update!(hash) }
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :footprint_value_updated,
        owner: current_user,
        trackable: ::AdminToolkit::FootprintValue.find_by(id: attributes.dig(0, :id)),
        parameters: attributes
      }
    end
  end
end
