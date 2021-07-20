# frozen_string_literal: true

module Penetrations
  class Transform
    ZIP = 0
    CITY = 1
    RATE = 2
    COMPETITION = 3
    KAM_REGION = 4
    FOOTPRINT = 5
    TYPE = 6

    using TextFormatter

    def process(row)
      format(row, ZIP, { action: [:to_i] })
      format(row, RATE, { action: [:*, 100] })
      format(row, FOOTPRINT, { action: [:to_boolean] })

      {
        zip: row[ZIP],
        city: row[CITY],
        rate: row[RATE],
        competition: row[COMPETITION],
        kam_region: row[KAM_REGION],
        hfc_footprint: row[FOOTPRINT],
        type: row[TYPE]
      }
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
