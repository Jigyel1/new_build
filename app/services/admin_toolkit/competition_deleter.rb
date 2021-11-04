# frozen_string_literal: true

module AdminToolkit
  class CompetitionDeleter < BaseService
    include CompetitionFinder

    def call
      authorize! competition, to: :destroy?, with: AdminToolkitPolicy

      with_tracking { competition.destroy! }
    end

    private

    def activity_params
      {
        action: :competition_deleted,
        owner: current_user,
        trackable: competition,
        parameters: competition.attributes.slice('name', 'factor', 'lease_rate')
      }
    end
  end
end
