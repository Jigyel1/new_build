# frozen_string_literal: true

module Buildings
  class TransformIdable < Transform
    BUILDING_ID = 6

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
