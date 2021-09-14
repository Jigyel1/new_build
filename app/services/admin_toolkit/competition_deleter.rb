# frozen_string_literal: true

module AdminToolkit
  class CompetitionDeleter < BaseService
    include CompetitionFinder

    def call
      authorize! competition, to: :destroy?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        competition.destroy!
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :competition_deleted,
        owner: current_user,
        trackable: competition,
        parameters: competition.attributes.slice('name', 'factor', 'lease_rate')
      }
    end
  end
end
