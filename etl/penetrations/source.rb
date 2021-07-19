module Penetrations
  class Source
    def initialize(sheet:)
      @sheet = sheet
    end

    def each
      @sheet.each_row { |row| yield(row) }
    end
  end
end
