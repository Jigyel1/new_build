# frozen_string_literal: true

module Buildings
  class TransformAddressable < Transform
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
      building.update!(external_id: row[EXTERNAL_ID], **building_attributes(row))
    end
  end
end
