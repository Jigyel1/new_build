# frozen_string_literal: true

module Projects
  module ProjectUpdaterHelper
    def update_project_date(buildings, project)
      dates = buildings.group_by(&:move_in_starts_on).keys.minmax
      project.update!(move_in_starts_on: dates[0], move_in_ends_on: (dates[1].presence || dates[0]))
    end
  end
end
