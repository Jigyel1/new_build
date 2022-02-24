# frozen_string_literal: true

module Penetrations
  class Source < EtlSource
    def each(&block)
      super do
        @sheet.to_a.group_by(&:itself).reject { |key, value| value.count > 1 }.keys.to_a
              .select { |row| row[PenetrationsImporter::ZIP].presence }
              .each(&block)
      end
    end
  end
end
