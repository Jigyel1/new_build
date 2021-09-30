# frozen_string_literal: true

module Projects
  class TransformProject
    include EtlHelper
    attr_reader :row, :attributes

    # values in these indexes need to be converted to integer.
    # Move the zip, etc of other modules to their respective transforms
    INTEGER_COLS = [1, 8, 23, 39, 55, 66, 76, 77, 82, 85, 90, 91].freeze
    EXTERNAL_ID = 1

    def initialize(errors)
      @errors = errors
    end

    def process(row)
      to_int(row)

      project = Project.find_or_initialize_by(external_id: row[EXTERNAL_ID])
      return if persisted?(project)

      project.define_singleton_method(:row) do
        row
      end

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
