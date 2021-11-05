# frozen_string_literal: true

module Projects
  class Organizer
    BUILDING_ID = 6
    STREET = 7
    STREET_NO = 8
    STREET_NO_SUFFIX = 9
    ZIP = 10
    CITY = 11

    attr_accessor(:buildings, :rows, :idable_buildings, :idable_rows, :addressable_buildings,
                  :addressable_rows, :ordered_buildings, :ordered_rows)

    def initialize(buildings:, rows:)
      @buildings = buildings.order(:external_id) # External ID will always be present.
      @rows = rows.sort { |row_1, row_2| row_1[BUILDING_ID] <=> row_2[BUILDING_ID] }
      @addressable_rows = []
      @addressable_buildings = []
    end

    # Processing priority building_id -> address -> tasks -> files
    def call
      load_matching_ids
      load_matching_addresses
      load_remaining
    end

    private

    # Loads all buildings that have a matching ID in the rows.
    def load_matching_ids
      @idable_rows = rows.select { |row| buildings.exists?(external_id: row[BUILDING_ID]) }

      @idable_buildings = buildings.select do |building|
        rows.find { |row| row[BUILDING_ID] == building.external_id.to_i }
      end
    end

    # TODO: This could be refactored further. Let's make it workable first.
    # Loads all buildings that have a matching address in the rows.
    def load_matching_addresses
      remaining_buildings = buildings.where.not(id: idable_buildings)
      (rows - idable_rows).each do |row|
        building = building_matching_address(
          remaining_buildings,
          stringify_address(row, [STREET, STREET_NO, STREET_NO_SUFFIX, ZIP, CITY])
        )
        next unless building

        @addressable_buildings << building
        @addressable_rows << row
        remaining_buildings = remaining_buildings.where.not(id: building)
      end
    end

    def building_matching_address(buildings, address)
      buildings.joins(:address).find do |building|
        stringify_address(building.address.attributes, %i[street street_no zip city]) == address
      end
    end

    def load_remaining
      @ordered_buildings = buildings.where
                                    .not(id: excluded_buildings_for_ordering)
                                    .left_joins(:tasks)
                                    .group(:id)
                                    .reorder('COUNT(projects_tasks.id) DESC', 'files_count DESC')

      @ordered_rows = rows - (idable_rows + addressable_rows)
    end

    def excluded_buildings_for_ordering
      (idable_buildings + addressable_buildings).pluck(:id)
    end

    def stringify_address(collection, keys)
      collection.symbolize_keys! if collection.is_a?(Hash)

      collection.values_at(*keys).join(' ').squish
    end
  end
end
