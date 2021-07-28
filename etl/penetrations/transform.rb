# frozen_string_literal: true

module Penetrations
  class Transform
    ZIP = 0
    RATE = 2
    COMPETITION = 3
    KAM_REGION = 4
    FOOTPRINT = 5

    # Don't change the order!
    HEADERS = %i[zip city rate competition_id kam_region_id hfc_footprint type].freeze

    using TextFormatter

    def process(row)
      format(row, ZIP, { action: [:to_i] })
      format(row, RATE, { action: [:*, 100] })
      format(row, FOOTPRINT, { action: [:to_boolean] })

      row[COMPETITION] = ::AdminToolkit::Competition.find_by!(name: row[COMPETITION]).id
      row[KAM_REGION] = ::AdminToolkit::KamRegion.find_by!(name: row[KAM_REGION]).id

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
