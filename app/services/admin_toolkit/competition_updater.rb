# frozen_string_literal: true

module AdminToolkit
  class CompetitionUpdater < BaseService
    include CompetitionFinder

    def call
      authorize! competition, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        competition.update!(attributes)
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :competition_updated,
        owner: current_user,
        trackable: competition,
        parameters: attributes.except(:id)
      }
    end
  end
end
