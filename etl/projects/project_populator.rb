require_relative '../../app/models/admin_toolkit'

module Projects
  class ProjectPopulator < BasePopulator
    # return <Project>
    # TODO: Use interactor organizer for this?
    def call
      super do
        assign_project_attributes
        assign_address_attributes
        assign_additional_details
        assign_kam_region
      end
    end

    private

    def execute?
      true
    end

    def assign_project_attributes
      attributes = row_mappings(:project)
      project.assign_attributes(attributes_hash(attributes))
    end

    def assign_address_attributes
      attributes = row_mappings(:project_address)
      super(attributes_hash(attributes), project)
    end

    def assign_additional_details
      attributes = row_mappings(:additional_details)
      project.additional_details = attributes_hash(attributes)
    end

    def assign_kam_region
      region_name = row[row_mappings(:kam_region_name)]
      return if region_name.blank?

      kam_region = AdminToolkit::KamRegion.find_by(name: region_name)
      if kam_region
        project.kam_region = kam_region
      else
        project.errors.add(:kam_region, I18n.t('activerecord.errors.models.project.kam_region_missing', region_name: region_name))
      end
    end
  end
end
