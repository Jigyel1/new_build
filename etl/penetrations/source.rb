# frozen_string_literal: true

module Penetrations
  class Source < EtlSource
    def each(&block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      sheets = []
      penetration = AdminToolkit::Penetration
      @sheet.to_a.group_by { |zip| zip[0] }.reject do |zip, row|
        sheets << row[0] if row.count == 1
        penetration.find_by(zip: zip).destroy if row.count == 1 && penetration.find_by(zip: zip).present?
      end

      super { sheets.select { |row| row[PenetrationsImporter::ZIP].presence }.each(&block) }
    end
  end
end
