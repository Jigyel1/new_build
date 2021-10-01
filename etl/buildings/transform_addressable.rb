# frozen_string_literal: true

module Buildings
  class TransformAddressable < Transform
    EXTERNAL_ID = 6
    APARTMENTS_COUNT = 15
    MOVE_IN_STARTS_ON = 22
    STREET = 7
    STREET_NO = 8
    BUILDING_NO = 9
    ZIP = 10
    CITY = 11

    def process(array)
      @organizer, @project = array

      process_addressable_rows
      [organizer, project]
    end

    private

    def process_addressable_rows
      addressable_buildings.zip(addressable_rows).each { |array| update_building(*array) }
    end

    def update_building(building, row)
      building.update!(
        external_id: row[EXTERNAL_ID],
        apartments_count: row[APARTMENTS_COUNT],
        move_in_starts_on: row[MOVE_IN_STARTS_ON].try(:to_date),
        additional_details: attributes_hash(row, BuildingsImporter::ATTRIBUTE_MAPPINGS[:additional_details]),
        address_attributes: {
          street: row[STREET],
          city: row[CITY],
          zip: row[ZIP],
          street_no: "#{row[STREET_NO]} #{row[BUILDING_NO]}".squish
        }
      )
    end
  end
end
