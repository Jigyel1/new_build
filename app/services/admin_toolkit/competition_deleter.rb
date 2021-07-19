# frozen_string_literal: true

module AdminToolkit
  class CompetitionDeleter < BaseService
    include CompetitionFinder

    private

    def process
      authorize! competition, to: :destroy?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        competition.destroy!
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def execute?
      true
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :competition_deleted,
        owner: current_user,
        trackable_type: 'AdminToolkit',
        parameters: attributes
      }
    end
  end
end
