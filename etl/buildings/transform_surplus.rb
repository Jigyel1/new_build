module Buildings
  class TransformSurplus
    extend Forwardable
    include Helper
    attr_reader :organizer, :project

    def_delegators :organizer, :ordered_buildings, :ordered_rows

    def initialize(errors)
      @errors = errors
    end

    # If the surplus is in the excel, create new buildings in the portal for the project
    # If the surplus is in the buildings for the project in the portal, delete those.
    def process(array)
      @organizer, @project = array

      if ordered_buildings.length > ordered_rows.size
        update_and_delete!
      else
        update_and_create!
      end
    end

    private

    def update_and_create!
      ordered_rows.zip(ordered_buildings).each do |array|
        row, building = array

        if building
          update_building!(building, row)
        else
          project.buildings.create!(
            name: "#{project.name} #{project.buildings.size + 1}",
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

    def update_and_delete!
      ordered_buildings.zip(ordered_rows).each do |array|
        building, row = array

        if row
          update_building!(building, row)
        else
          building.destroy!
        end
      end
    end

    def update_building!(building, row)
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
