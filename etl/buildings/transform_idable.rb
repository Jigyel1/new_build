# frozen_string_literal: true

module Buildings
  class TransformIdable < Transform
    def process(array)
      @project, @rows = array
      rows.map(&:pop)

      organizer.call
      process_idable_rows

      [organizer, project]
    end

    def organizer
      @organizer ||= Projects::Organizer.new(buildings: project.buildings, rows: rows)
    end

    private

    def process_idable_rows
      idable_buildings.zip(idable_rows).each { |array| update_building(*array) }
    end

    def update_building(building, row)
      building.update!(building_attributes(row))
    end
  end
end
