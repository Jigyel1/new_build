# frozen_string_literal: true

module Projects
  class CategorySetter < BaseService
    attr_accessor :project

    def call
      AdminToolkit::FootprintValue
        .joins(:footprint_building, :footprint_type)
        .where(
          'admin_toolkit_footprint_buildings.min <= :value AND admin_toolkit_footprint_buildings.max >= :value',
          value: project.buildings_count
        ).find_by(admin_toolkit_footprint_types: { provider: provider })
        .try(:category)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    private

    def penetration
      AdminToolkit::Penetration.find_by!(zip: project.zip)
    end

    # TODO: add a code to the competition to make checks like this more concrete.
    def provider
      sfn = penetration.competitions.exists?(name: 'FTTH SFN')
      hfc = penetration.hfc_footprint

      if sfn && hfc then :both
      elsif sfn then :ftth_sfn
      elsif hfc then :ftth_swisscom
      else :neither
      end
    end
  end
end
