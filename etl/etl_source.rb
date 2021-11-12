# frozen_string_literal: true

class EtlSource
  def initialize(sheet:)
    @sheet = sheet
  end

  def each(&block)
    ActiveRecord::Base.transaction do
      block&.call
    end
  end
end
