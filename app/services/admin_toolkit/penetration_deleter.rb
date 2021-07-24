# frozen_string_literal: true

module AdminToolkit
  class PenetrationDeleter < BaseService
    include PenetrationFinder

    def call
      authorize! penetration, to: :destroy?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        penetration.destroy!
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :penetration_deleted,
        owner: current_user,
        trackable: penetration,
        parameters: penetration.attributes.slice(
          'zip', 'city', 'rate', 'competition', 'kam_region', 'hfc_footprint', 'type'
        )
      }
    end
  end
end
