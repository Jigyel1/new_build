# frozen_string_literal: true

module Penetrations
  class Transform
    RATE = 2
    COMPETITION = 3
    KAM_REGION = 3
    FOOTPRINT = 5

    using TextFormatter

    # Don't change the order!
    HEADERS = %i[zip city rate kam_region_id hfc_footprint type strategic_partner].freeze

    def process(row)
      format_each(row)

      penetration = AdminToolkit::Penetration.find_or_initialize_by(zip: row[PenetrationsImporter::ZIP])
      competition = row.delete_at(COMPETITION)

      penetration.assign_attributes(HEADERS.zip(row).to_h)

      penetration.kam_region = ::AdminToolkit::KamRegion.find_by(name: row[KAM_REGION])
      build_competition(penetration, competition.split(','))
      penetration
    rescue ActiveRecord::RecordNotFound => e
      $stdout.write("#{e} for penetration with zip #{penetration.zip}\n")
      raise
    end

    private

    def build_competition(penetration, competitions)
      admintoolkit_penetration = AdminToolkit::Penetration.find_by(zip: penetration.zip)
      admintoolkit_penetration.competitions.delete_all if admintoolkit_penetration.try(:competitions).present?

      competitions.each do |name|
        competition = ::AdminToolkit::Competition.find_by(name: name.strip)
        penetration.penetration_competitions.find_or_initialize_by(competition: competition)
      end
    end

    def format_each(row)
      row[PenetrationsImporter::ZIP] = row[PenetrationsImporter::ZIP].try(:to_i)
      row[FOOTPRINT] = row[FOOTPRINT].to_boolean
    end
  end
end
