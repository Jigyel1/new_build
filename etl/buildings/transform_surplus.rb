# frozen_string_literal: true

module Buildings
  class TransformSurplus < Transform
    # If the surplus is in the excel, create new buildings in the portal for the project
    # If the surplus is in the portal, delete those.
    def process(array)
      @organizer, @project = array

      if ordered_buildings.length > ordered_rows.length
        update_and_delete!
      else
        update_and_create!
      end
    end

    private

    def update_and_create! # rubocop:disable Metrics/AbcSize
      ordered_rows.zip(ordered_buildings).each do |array|
        row, building = array

        if building
          update_building!(building, row)
        else
          project.buildings.create!(
            name: "#{project.name} #{project.buildings.size + 1}",
            external_id: row[EXTERNAL_ID].to_i,
            **building_attributes(row)
          )
        end
      end
    end

    def update_and_delete!
      ordered_buildings.zip(ordered_rows).each do |array|
        building, row = array
        row ? update_building!(building, row) : building.destroy!
      end
    end

    def update_building!(building, row)
      building.update!(external_id: row[EXTERNAL_ID].to_i, **building_attributes(row))
    end
  end
end
