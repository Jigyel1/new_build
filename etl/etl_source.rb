# frozen_string_literal: true

class EtlSource
  def initialize(sheet:)
    @sheet = sheet
  end

  def each(&block)
    ActiveRecord::Base.transaction do
      @sheet.each_row(&block)
    end
  end
end
