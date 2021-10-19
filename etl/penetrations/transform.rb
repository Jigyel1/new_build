# frozen_string_literal: true

module Penetrations
  class Transform
    ZIP = 0
    RATE = 2
    COMPETITION = 3
    KAM_REGION = 3
    FOOTPRINT = 5

    using TextFormatter

    # Don't change the order!
    HEADERS = %i[zip city rate kam_region_id hfc_footprint type].freeze

    def process(row)
      format(row, ZIP, { action: [:to_i] })
      format(row, RATE, { action: [:*, 100] })
      format(row, FOOTPRINT, { action: [:to_boolean] })

      penetration = AdminToolkit::Penetration.find_or_initialize_by(zip: row[ZIP])
      competition = ::AdminToolkit::Competition.find_by!(name: row.delete_at(COMPETITION))

      penetration.assign_attributes(HEADERS.zip(row).to_h)

      penetration.kam_region = ::AdminToolkit::KamRegion.find_by!(name: row[KAM_REGION])
      penetration.penetration_competitions.find_or_initialize_by(competition: competition)
    rescue ActiveRecord::RecordNotFound => e
      $stdout.write("#{e.to_s} for penetration with zip #{penetration.zip}\n")
      raise
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
