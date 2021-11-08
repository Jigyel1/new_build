# frozen_string_literal: true

module AdminToolkit
  class PenetrationDeleter < BaseService
    include PenetrationFinder

    def call
      authorize! penetration, to: :destroy?, with: AdminToolkitPolicy

      with_tracking { penetration.destroy! }
    end

    private

    def activity_params
      {
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
