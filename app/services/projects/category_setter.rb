module Projects
  class CategorySetter < BaseService
    attr_accessor :project

    def call
      AdminToolkit::FootprintValue
        .joins(:footprint_building, :footprint_type)
        .where('admin_toolkit_footprint_buildings.min <= :value AND admin_toolkit_footprint_buildings.max >= :value', value: project.buildings_count)
        .find_by(admin_toolkit_footprint_types: { provider: provider })
        .try(:project_type)
    rescue ActiveRecord::RecordNotFound # return default category for projects there is no corresponding zip in penetrations.
      :complex
    end

    private

    def penetration
      AdminToolkit::Penetration.find_by!(zip: project.zip)
    end

    def provider
      sfn = penetration.competitions.exists?(name: 'FTTH SFN')
      hfc = penetration.hfc_footprint

      case
      when sfn && hfc then :both
      when sfn then :ftth_sfn
      when hfc then :ftth_swisscom
      else :neither
      end
    end
  end
end
