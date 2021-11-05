# frozen_string_literal: true

module AdminToolkit
  class PenetrationCreator < BaseService
    attr_reader :penetration

    def call
      authorize! ::AdminToolkit::Penetration, to: :create?, with: AdminToolkitPolicy

      with_tracking do
        @penetration = ::AdminToolkit::Penetration.new(attributes)

        # FE sends rate in percentage. Convert that to fraction/decimal before saving.
        penetration.rate = penetration.rate / 100
        penetration.save!
      end
    end

    private

    def activity_params
      {
        action: :penetration_created,
        owner: current_user,
        trackable: penetration,
        parameters: attributes
      }
    end
  end
end
