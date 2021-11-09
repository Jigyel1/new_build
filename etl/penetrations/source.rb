# frozen_string_literal: true

module Penetrations
  class Source < EtlSource
    def each(&block)
      super do
        @sheet.to_a
              .select { |row| row[PenetrationsImporter::ZIP] && row }
              .each(&block)
      end
    end
  end
end
