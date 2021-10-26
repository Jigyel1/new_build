# frozen_string_literal: true

module AdminToolkit
  class PenetrationCreator < BaseService
    attr_reader :penetration

    def call
      authorize! ::AdminToolkit::Penetration, to: :create?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        @penetration = ::AdminToolkit::Penetration.new(attributes)

        # FE sends rate in percentage. Convert that to fraction/decimal before saving.
        penetration.rate = penetration.rate / 100
        penetration.save!

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :penetration_created,
        owner: current_user,
        trackable: penetration,
        parameters: attributes
      }
    end
  end
end
