# frozen_string_literal: true

class EtlSource
  def initialize(sheet:)
    @sheet = sheet
  end

  def each(&block)
    @sheet.each_row(&block)
  end
end
