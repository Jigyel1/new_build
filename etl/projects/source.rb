# frozen_string_literal: true

module Projects
  class Source < EtlSource
    def each(&block)
      super do
        @sheet.to_a
              .select { |row| row[ProjectsImporter::EXTERNAL_ID] && row }
              .each(&block)
      end
    end
  end
end
