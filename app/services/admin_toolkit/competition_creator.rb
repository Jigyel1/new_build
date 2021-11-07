# frozen_string_literal: true

module AdminToolkit
  class CompetitionCreator < BaseService
    attr_reader :competition

    def call
      authorize! ::AdminToolkit::Competition, to: :create?, with: AdminToolkitPolicy

      with_tracking { @competition = ::AdminToolkit::Competition.create!(attributes) }
    end

    private

    def activity_params
      {
        action: :competition_created,
        owner: current_user,
        trackable: competition,
        parameters: attributes
      }
    end
  end
end
