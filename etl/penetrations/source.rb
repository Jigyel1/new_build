# frozen_string_literal: true

module Penetrations
  class Source < EtlSource
    def each(&block)
      sheets = []
      @sheet.to_a.group_by { |zip| zip[0] }.reject { |_zip, row| sheets << row[0] if row.count == 1 }

      super { sheets.select { |row| row[PenetrationsImporter::ZIP].presence }.each(&block) }
    end
  end
end
