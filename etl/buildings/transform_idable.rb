# frozen_string_literal: true

module Buildings
  class TransformIdable
    include Helper
    BUILDING_ID = 6

    attr_reader :rows, :project

    def initialize(errors)
      @errors = errors
    end

    def process(array)
      @project, @rows = array
      rows.map(&:pop)

      organizer.call
      process_idable_rows

      [organizer, project]
    end

    private

    def organizer
      @organizer ||= Projects::Organizer.new(buildings: project.buildings, rows: rows)
    end

    def process_idable_rows
      organizer.idable_buildings.zip(organizer.idable_rows).each { |array| update_building(*array) }
    end

    def update_building(building, row)
      building.update!(
        apartments_count: row[15].to_i,
        move_in_starts_on: row[22].try(:to_date),
        additional_details: attributes_hash(row, BuildingsImporter::ATTRIBUTE_MAPPINGS[:additional_details]),
        address_attributes: {
          street: row[7],
          city: row[11],
          zip: row[10],
          street_no: "#{row[8]} #{row[9]}".squish
        }
      )
    end
  end
end
