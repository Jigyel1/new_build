# frozen_string_literal: true

module AdminToolkit
  class CompetitionUpdater < BaseService
    include CompetitionFinder

    private

    def process
      authorize! competition, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        competition.update!(attributes)
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def execute?
      true
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :competition_updated,
        owner: current_user,
        trackable_type: 'AdminToolkit',
        parameters: attributes
      }
    end
  end
end
