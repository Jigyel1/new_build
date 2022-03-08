# frozen_string_literal: true

module Penetrations
  class Source < EtlSource
    def each(&block)
      sheets = []
      @sheet.to_a.group_by { |zip| zip[0] }.each_pair do |value|
        sheets << value[0] if value.count == 1
      end

      super { sheets.select { |row| row[PenetrationsImporter::ZIP].presence }.each(&block) }
    end
  end
end
