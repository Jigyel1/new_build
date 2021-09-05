# frozen_string_literal: true

module Buildings
  class Source
    include EtlHelper

    PROJECT_INTERNAL_ID = 0
    PROJECT_EXTERNAL_ID = 5
    LAST_INDEX = 66
    TO_INTS = [0, 5, 6, 8, 10, 13, 15, 17, 18, 19, 25, 26, 27, 29, 31, 32, 35, 37, 39, 40, 59, 60, 65].freeze

    def initialize(sheet:)
      @sheet = sheet
    end

    def each(&block)
      array = []
      @sheet.each_row do |row|
        row[LAST_INDEX] = Project.find_by(lookup_hash(row))
        next unless row[LAST_INDEX]

        array << row
      end

      array.each { |row| to_int(row) }

      grouped = array.group_by { |row| row[LAST_INDEX] }
      grouped.each_pair(&block)
    end

    private

    def lookup_hash(row)
      if row[PROJECT_EXTERNAL_ID]
        { external_id: row[PROJECT_EXTERNAL_ID].to_i }
      else
        { internal_id: row[PROJECT_INTERNAL_ID].to_i }
      end
    end
  end
end
