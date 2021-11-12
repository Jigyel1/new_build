# frozen_string_literal: true

module Projects
  class Source < EtlSource
    def each(&block)
      super do
        @sheet.to_a
              .select { |row| row[ProjectsImporter::EXTERNAL_ID].presence }
              .each(&block)
      end
    end
  end
end
