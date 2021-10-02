# frozen_string_literal: true

require_relative '../../app/models/admin_toolkit'

module Projects
  class ProjectPopulator < BasePopulator
    BUILDINGS_COUNT_COL = 76
    APARTMENTS_COUNT_COL = 77

    # Note: project category should be called only after assigning the buildings.
    def call
      super do
        %i[
          project_attributes
          address_attributes
          additional_details
          kam_region
          buildings
          project_category
        ].each { |attributes| send("assign_#{attributes}") }
      end
    end

    private

    def execute?
      true
    end

    def assign_project_attributes
      attributes = row_mappings(:project)
      project.assign_attributes(attributes_hash(attributes))
      project.entry_type = :info_manager
    end

    def assign_address_attributes
      attributes = row_mappings(:project_address)
      super(attributes_hash(attributes), project)
    end

    def assign_buildings
      Projects::BuildingsBuilder.new(
        project: project,
        buildings_count: row[BUILDINGS_COUNT_COL],
        apartments_count: row[APARTMENTS_COUNT_COL]
      ).call
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
        project.errors.add(
          :kam_region,
          I18n.t('activerecord.errors.models.project.kam_region_missing', region_name: region_name)
        )
      end
    end

    def assign_project_category
      project.category = Projects::CategorySetter.new(project: project).call
    end
  end
end
