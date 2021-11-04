# frozen_string_literal: true

module AdminToolkit
  class CompetitionUpdater < BaseService
    include CompetitionFinder

    def call
      authorize! competition, to: :update?, with: AdminToolkitPolicy

      with_tracking { competition.update!(attributes) }
    end

    private

    def activity_params
      {
        action: :competition_updated,
        owner: current_user,
        trackable: competition,
        parameters: attributes.except(:id)
      }
    end
  end
end
