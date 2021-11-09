# frozen_string_literal: true

#
# This class facilitates the update of buildings from an excel.
#
# Buildings are grouped as follows:
#
# - idable_buildings: buildings with matching ids in the rows of the excel.
#
# - addressable_buildings: buildings with matching addresses in the rows of the excel excluding
# the <tt>idable_buildings</tt>.
#
# - ordered_buildings: buildings excluding the <tt>idable_buildings</tt> and <tt>addressable_buildings</tt>
# in descending order of count tasks and files count.
#
# Rows are grouped as <tt>idable_rows, addressable_rows, ordered_rows</tt> in a similar fashion.
#
# @param [buildings] buildings for a given project
# @param [rows] rows grouped by project
module Projects
  class Organizer
    BUILDING_ID = 6
    STREET = 7
    STREET_NO = 8
    STREET_NO_SUFFIX = 9
    ZIP = 10
    CITY = 11

    ATTRS = %i[
      buildings rows
      idable_buildings idable_rows
      addressable_buildings addressable_rows
      ordered_buildings ordered_rows
    ].freeze

    attr_accessor(*ATTRS)

    def initialize(buildings:, rows:)
      @buildings = buildings.order(:external_id) # External ID will always be present.
      @rows = rows.sort { |row_1, row_2| row_1[BUILDING_ID] <=> row_2[BUILDING_ID] }
      @addressable_rows = []
      @addressable_buildings = []
    end

    def call
      load_idable
      load_addressable
      load_orderable
    end

    private

    # Loads all buildings that have a matching ID in the rows.
    def load_idable
      @idable_rows = rows.select do |row|
        row[BUILDING_ID].present? && buildings.exists?(external_id: row[BUILDING_ID])
      end

      @idable_buildings = buildings.select do |building|
        rows.find { |row| row[BUILDING_ID] == building.external_id.to_i }
      end
    end

    # Loads all buildings that have a matching address in the rows.
    def load_addressable
      remaining_buildings = buildings - idable_buildings

      (rows - idable_rows).each do |row|
        building = building_matching_address(
          remaining_buildings,
          stringify_address(row, [STREET, STREET_NO, STREET_NO_SUFFIX, ZIP, CITY])
        )
        next unless building

        @addressable_buildings << building
        @addressable_rows << row

        # after an address match, remove that building from the remaining buildings so that it is not loaded again.
        remaining_buildings -= [building]
      end
    end

    def building_matching_address(buildings, address)
      Projects::Building.where(id: buildings).joins(:address).find do |building|
        stringify_address(building.address.attributes, %i[street street_no zip city]) == address
      end
    end

    def load_orderable
      @ordered_buildings = buildings.where
                                    .not(id: (idable_buildings + addressable_buildings))
                                    .left_joins(:tasks)
                                    .group(:id)
                                    .reorder('COUNT(projects_tasks.id) DESC', 'files_count DESC')

      @ordered_rows = order_rows
    end

    # Rows that aren't idable or addressable.
    # Note: rows - (idable_rows + addressable_rows) won't work if there are duplicates.
    #
    # Example
    #   [[1, 2], [1, 2]] - [[1, 2]]
    #   #=> [] instead of [[1, 2]]
    # Hence the workaround.
    def order_rows
      rows_taken = idable_rows + addressable_rows

      rows.select do |row|
        if rows_taken.include?(row)
          rows_taken -= [row]
          next
        else
          row
        end
      end
    end

    def stringify_address(collection, keys)
      collection.symbolize_keys! if collection.is_a?(Hash)

      collection.values_at(*keys).join(' ').squish
    end
  end
end
