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

    def update_and_create! # rubocop:disable Metrics/AbcSize, Metrics/SeliseMethodLength
      ordered_rows.zip(ordered_buildings).each do |array|
        row, building = array

        with_error_formatting(row) do
          if building
            update_building!(building, row)
          else
            project.buildings.create!(
              name: "#{project.name} #{project.buildings.size + 1}",
              external_id: row[EXTERNAL_ID].try(:to_i),
              **building_attributes(row)
            )
          end
        end
      end
    end

    def update_and_delete!
      ordered_buildings.zip(ordered_rows).each do |array|
        building, row = array
        with_error_formatting(building) { row ? update_building!(building, row) : building.destroy! }
      end
    end

    def update_building!(building, row)
      building.update!(external_id: row[EXTERNAL_ID].try(:to_i), **building_attributes(row))
    end

    def with_error_formatting(record)
      yield if block_given?
    rescue ActiveRecord::RecordInvalid => e
      raise case record.class
            when Array
              "Import failed for row with PRONUM `COLUMN 0(#{row[0]})` and PROJ_EXTERN_ID `COLUMN 59(#{row[59]})`"\
              "with error #{e}"
            when Projects::Building
              "Import failed for building with id `#{building.id}` and name `#{building.name}` with error #{e}"
            else e.to_s
            end
    end
  end
end
