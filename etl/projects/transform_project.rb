# frozen_string_literal: true

module Projects
  class TransformProject
    attr_reader :row, :attributes

    # values in these indexes need to be converted to integer.
    # Move the zip, etc of other modules to their respective transforms
    TO_INTS = [1, 2, 8, 17, 23, 33, 49, 39, 55, 66, 76, 77, 82, 85, 90, 91].freeze
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

    def to_int(row)
      TO_INTS.each do |index|
        value = row[index]
        next if value.blank?

        row[index] = row[index].to_i
      end
    end

    def persisted?(project)
      return unless project.persisted?

      @errors << I18n.t('activerecord.errors.models.project.exists', id: project.external_id)
      true
    end
  end
end
