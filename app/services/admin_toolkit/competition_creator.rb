# frozen_string_literal: true

module AdminToolkit
  class CompetitionCreator < BaseService
    attr_reader :competition

    def call
      authorize! ::AdminToolkit::Competition, to: :create?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        @competition = ::AdminToolkit::Competition.create!(attributes)
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :competition_created,
        owner: current_user,
        trackable: competition,
        parameters: attributes
      }
    end
  end
end
