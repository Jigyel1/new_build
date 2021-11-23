# frozen_string_literal: true

module Projects
  class CompetitionSetter < BaseService
    attr_accessor :project

    def call
      competitions.first if penetration.present? && competitions.count == 1
    end

    private

    def competitions
      @_competitions ||= penetration.competitions
    end

    def penetration
      @_penetration ||= AdminToolkit::Penetration.find_by(zip: project.zip)
    end
  end
end
