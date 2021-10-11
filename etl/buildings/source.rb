# frozen_string_literal: true

module Buildings
  class Source < EtlSource
    include EtlHelper

    PROJECT_INTERNAL_ID = 0
    PROJECT_EXTERNAL_ID = 5
    LAST_INDEX = 66
    INTEGER_COLS = FileParser.parse { 'etl/buildings/integer_columns.yml' }.keys.freeze

    def each(&block)
      array = []
      @sheet.each_row do |row|
        row[LAST_INDEX] = Project.find_by(lookup_hash(row))
        next unless row[LAST_INDEX]

        array << row
      end

      # the integers in excel are reflected here as floats. Hence the conversion.
      array.each { |row| to_int(row) }

      # group buildings by projects and update wrt a project(row[LAST_INDEX])
      grouped = array.group_by { |row| row[LAST_INDEX] }

      ActiveRecord::Base.transaction { grouped.each_pair(&block) }
    end

    private

    # If external id is present then use that for fetching projects.
    # Else use the internal id for project lookup.
    def lookup_hash(row)
      if row[PROJECT_EXTERNAL_ID]
        { external_id: row[PROJECT_EXTERNAL_ID].to_i }
      else
        { internal_id: row[PROJECT_INTERNAL_ID].to_i }
      end
    end
  end
end
