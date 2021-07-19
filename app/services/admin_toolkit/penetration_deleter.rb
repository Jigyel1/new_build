# frozen_string_literal: true

module AdminToolkit
  class PenetrationDeleter < BaseService
    include PenetrationFinder

    private

    def process
      authorize! penetration, to: :destroy?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        penetration.destroy!
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def execute?
      true
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :penetration_deleted,
        owner: current_user,
        trackable_type: 'AdminToolkit',
        parameters: attributes
      }
    end
  end
end
