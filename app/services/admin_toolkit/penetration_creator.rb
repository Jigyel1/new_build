# frozen_string_literal: true

module AdminToolkit
  class PenetrationCreator < BaseService
    attr_reader :penetration

    private

    def process
      authorize! ::AdminToolkit::Penetration, to: :create?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        @penetration = ::AdminToolkit::Penetration.create!(attributes)
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def execute?
      true
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :penetration_created,
        owner: current_user,
        trackable_type: 'AdminToolkit',
        parameters: attributes
      }
    end
  end
end
