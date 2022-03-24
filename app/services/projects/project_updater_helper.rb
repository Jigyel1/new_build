# frozen_string_literal: true

module Projects
  module ProjectUpdaterHelper
    def update_project_date(buildings, project)
      dates = buildings.group_by(&:move_in_starts_on).keys.compact.minmax
      project.update!(move_in_starts_on: dates.first, move_in_ends_on: dates.last)
    end
  end
end
