module AdminToolkit
  module CompetitionFinder
    def competition
      @_competition ||= AdminToolkit::Competition.find(attributes[:id])
    end
  end
end