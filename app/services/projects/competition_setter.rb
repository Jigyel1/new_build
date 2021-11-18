# frozen_string_literal: true

module Projects
  class CompetitionSetter < BaseService
    attr_accessor :project

    def call
      competitions.first unless competitions.count == 1
    end

    private

    def competitions
      @_competitions ||= AdminToolkit::Penetration.find_by!(zip: project.zip).competitions
    end
  end
end
