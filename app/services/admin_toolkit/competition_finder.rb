# frozen_string_literal: true

module AdminToolkit
  module CompetitionFinder
    def competition
      @competition ||= AdminToolkit::Competition.find(attributes[:id])
    end
  end
end
