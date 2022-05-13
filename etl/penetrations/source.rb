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

    # This method removes the array elements of type string with leading and trailing whitespaces
    # Then the integer value is inserted back again and formatted array is returned.
    def format(value)
      value.map do |index|
        index.instance_of?(String) ? index.strip : index
      end
    end
  end
end
