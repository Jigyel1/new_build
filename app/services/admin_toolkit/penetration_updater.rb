# frozen_string_literal: true

module AdminToolkit
  class PenetrationUpdater < BaseService
    include PenetrationFinder

    def call
      authorize! penetration, to: :update?, with: AdminToolkitPolicy

      with_tracking do
        with_uniqueness_check(:competition) { penetration.update!(attributes) }
      end
    end

    private

    def activity_params
      {
        action: :penetration_updated,
        owner: current_user,
        trackable: penetration,
        parameters: attributes.except(:id)
      }
    end
  end
end
