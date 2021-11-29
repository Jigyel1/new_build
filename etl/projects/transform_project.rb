# frozen_string_literal: true

module Projects
  class TransformProject
    include EtlHelper
    attr_reader :row, :attributes

    # values in these indexes need to be converted to integer.
    # Move the zip, etc of other modules to their respective transforms
    INTEGER_COLS = FileParser.parse { 'etl/projects/integer_columns.yml' }.keys

    def initialize(errors)
      @errors = errors
    end

    def process(row)
      # the integers in excel are reflected here as floats. Hence the conversion.
      to_int(row)

      project = initialize_project(row[ProjectsImporter::EXTERNAL_ID])

      project = discard_archived!(project)
      return if persisted?(project)

      project.define_singleton_method(:row) { row }

      ProjectPopulator.new(project).call
    end

    private

    # If a project is archived, soft delete the project. Create a new project with details from the row
    # and proceed with the etl pipeline to update its associations.
    def discard_archived!(project)
      return project unless project.archived?

      project.discard!
      project.update_column(:external_id, "#{project.external_id}_#{Time.current.to_i}")

      initialize_project(project.external_id).tap { |proj| proj.status = :technical_analysis }
    end

    def initialize_project(external_id)
      Project.find_or_initialize_by(external_id: external_id)
    end

    def persisted?(project)
      return unless project.persisted?

      @errors << I18n.t('activerecord.errors.models.project.exists', id: project.external_id)
      true
    end
  end
end
