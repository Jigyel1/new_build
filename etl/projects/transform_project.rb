# frozen_string_literal: true

module Projects
  class TransformProject
    include EtlHelper
    attr_reader :row, :attributes

    # values in these indexes need to be converted to integer.
    # Move the zip, etc of other modules to their respective transforms
    INTEGER_COLS = FileParser.parse { 'etl/projects/integer_columns.yml' }.keys
    EXTERNAL_ID = 1

    def initialize(errors)
      @errors = errors
    end

    def process(row)
      # the integers in excel are reflected here as floats. Hence the conversion.
      to_int(row)

      project = Project.find_or_initialize_by(external_id: row[EXTERNAL_ID])
      return if persisted?(project)

      project.define_singleton_method(:row) { row }

      ProjectPopulator.new(project).call
    end

    private

    def persisted?(project)
      return unless project.persisted?

      @errors << I18n.t('activerecord.errors.models.project.exists', id: project.external_id)
      true
    end
  end
end
