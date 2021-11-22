# frozen_string_literal: true

require_relative '../../app/models/admin_toolkit'

module Projects
  class ProjectPopulator < BasePopulator
    BUILDINGS_COUNT_COL = 75
    APARTMENTS_COUNT_COL = 76

    # NOTE: project category should be called only after assigning the buildings.
    def call
      super do
        %i[
          project_attributes
          address_attributes
          additional_details
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

    def assign_project_category
      project.category = Projects::CategorySetter.new(project: project).call
    end

    def assign_project_competition
      project.competition = CompetitionSetter.new(project: project).call
    end
  end
end
