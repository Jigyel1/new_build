# frozen_string_literal: true

module Projects
  class CategorySetter < BaseService
    attr_accessor :project

    def call
      AdminToolkit::FootprintValue
        .joins(:footprint_apartment, :footprint_type)
        .where(
          'admin_toolkit_footprint_apartments.min <= :value AND admin_toolkit_footprint_apartments.max >= :value',
          value: project.buildings.sum(&:apartments_count) # look for size in memory, not from the db.
        ).find_by(admin_toolkit_footprint_types: { provider: provider })
        .try(:category)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    private

    def penetration
      @_penetration ||= AdminToolkit::Penetration.find_by!(zip: project.zip)
    end

    def provider
      sfn = penetration.competitions.exists?(sfn: true)
      hfc = penetration.hfc_footprint

      if sfn && hfc then :both
      elsif sfn then :ftth_sfn
      elsif hfc then :ftth_swisscom
      else :neither
      end
    end
  end
end
