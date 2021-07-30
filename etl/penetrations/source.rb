# frozen_string_literal: true

module Penetrations
  class Source
    def initialize(sheet:)
      @sheet = sheet
    end

    def each(&block)
      @sheet.each_row(&block)
    end
  end
end