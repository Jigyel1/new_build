# frozen_string_literal: true

class EtlSource
  def initialize(sheet:)
    @sheet = sheet
  end

  def each
    ActiveRecord::Base.transaction do
      yield if block_given?
    end
  end
end
