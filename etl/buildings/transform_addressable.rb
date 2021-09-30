# frozen_string_literal: true

module Buildings
  class TransformAddressable < Transform
    BUILDING_ID = 6

    def process(array)
      @organizer, @project = array
      process_addressable_rows
      [organizer, @project]
    end

    private

    def process_addressable_rows
      addressable_buildings.zip(addressable_rows).each { |array| update_building(*array) }
    end

    def update_building(building, row)
      building.update!(
        external_id: row[6].to_i,
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
