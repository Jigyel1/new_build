# frozen_string_literal: true

module AdminToolkit
  class PenetrationUpdater < BaseService
    include PenetrationFinder

    def call
      authorize! penetration, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        penetration.update!(attributes)
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :penetration_updated,
        owner: current_user,
        trackable: penetration,
        parameters: attributes.except(:id)
      }
    end
  end
end
