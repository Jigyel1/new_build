module Projects
  class Organizer
    BUILDING_ID = 6
    STREET = 7
    STREET_NO = 8
    STREET_NO_SUFFIX = 9
    ZIP = 10
    CITY = 11

    attr_accessor :buildings, :rows
    attr_accessor :idable_buildings, :idable_rows, :addressable_buildings, :addressable_rows, :ordered_buildings, :ordered_rows

    # External ID will always be there.
    def initialize(buildings:, rows:)
      @buildings = buildings.order(:external_id)
      @rows = rows.sort { |row_1, row_2| row_1[BUILDING_ID] <=> row_2[BUILDING_ID] }
      @addressable_rows = Set.new
      @addressable_buildings = Set.new
    end

    # PRIORITY building_id -> address -> tasks -> files
    def call
      load_matching_ids
      load_matching_addresses
      load_remaining
    end

    private

    def load_matching_ids
      @idable_rows = rows.select { |row| buildings.exists?(external_id: row[BUILDING_ID]) }
      @idable_buildings = buildings.select { |building| rows.find { |row| row[BUILDING_ID] == building.external_id.to_i } }
    end

    def load_matching_addresses
      rows.each do |row|
        address_str = stringify_address(row, [STREET, STREET_NO, STREET_NO_SUFFIX, ZIP, CITY])

        buildings.joins(:address).each do |building|
          if stringify_address(building.address.attributes, [:street, :street_no, :zip, :city]) == address_str
            @addressable_buildings << building
            @addressable_rows << row
          end
        end
      end
    end

    def load_remaining
      @ordered_buildings = buildings.where
                                    .not(id: excluded_buildings_for_ordering)
                                    .left_outer_joins(:tasks, :files_attachments)
                                    .group(:id)
                                    .reorder('COUNT(projects_tasks.id) DESC', 'COUNT(active_storage_attachments.id) DESC')

      @ordered_rows = rows - (idable_rows + addressable_rows.to_a)
    end

    def excluded_buildings_for_ordering
      (idable_buildings + addressable_buildings.to_a).pluck(:id)
    end

    def stringify_address(collection, keys)
      collection.symbolize_keys! if collection.is_a?(Hash)

      collection.values_at(*keys).join(' ').squish
    end
  end
end
