# frozen_string_literal: true

module Penetrations
  class Transform
    ZIP = 0
    RATE = 2
    FOOTPRINT = 5

    # Don't change the order!
    HEADERS = %i[zip city rate competition kam_region hfc_footprint type].freeze

    using TextFormatter

    def process(row)
      format(row, ZIP, { action: [:to_i] })
      format(row, RATE, { action: [:*, 100] })
      format(row, FOOTPRINT, { action: [:to_boolean] })

      HEADERS.zip(row).to_h
    end

    private

    def format(*args)
      options = args.extract_options!
      row, index = args
      return if row[index].blank?

      row[index] = row[index].send(*options[:action])
      row
    end
  end
end
