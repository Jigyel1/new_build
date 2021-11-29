# frozen_string_literal: true

module Projects
  class CompetitionSetter < BaseService
    attr_accessor :project

    def call
      sole, undesired = AdminToolkit::Competition.joins(:penetrations).where(
        penetrations: { zip: project.zip }
      )

      sole unless undesired
    end
  end
end
