# frozen_string_literal: true

module Penetrations
  class Source < EtlSource
    def each(&block)
      sheets = []
      @sheet.to_a.group_by { |zip| zip[0] }.each_value do |value|
        sheets << format(value[0]) if value.count == 1
      end

      super { sheets.select { |row| row[PenetrationsImporter::ZIP].presence }.each(&block) }
    end

    # This method removes the array with nil elements and removes leading and trailing whitespaces
    # in the string. Then the integer value is inserted back again and formatted array is returned.
    def format(value)
      new_value = value.compact
      new_value.delete_at(0) && new_value.delete_at(1)
      formatted_value = new_value.collect(&:strip)
      formatted_value.insert(0, value[0]) && formatted_value.insert(2, value[2])
    end
  end
end
