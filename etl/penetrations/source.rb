# frozen_string_literal: true

module Penetrations
  class Source < EtlSource
    def each(&block)
      sheets = []
      @sheet.to_a.group_by { |i| i[0] }.reject { |_key, value| sheets << value[0] if value.count == 1 }

      super { sheets.select { |row| row[PenetrationsImporter::ZIP].presence }.each(&block) }
    end
  end
end
