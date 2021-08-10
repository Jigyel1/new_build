# frozen_string_literal: true

module Projects
  class Destination
    def initialize(errors)
      @errors = errors
    end

    def write(project)
      # Store the errors set during the transformation pipeline as it will be lost with `project.save!`
      errors_before_save = project.errors.full_messages

      project.save!
    rescue ActiveRecord::RecordInvalid
      # pop the in-memory errors to avoid reloading it in the ensure block.
      project.errors.full_messages << errors_before_save.pop
      @errors << "Project #{project.external_id} => #{project.errors.full_messages.to_sentence}"
    ensure
      @errors << "Project #{project.external_id} => #{errors_before_save.to_sentence}" if errors_before_save.present?
    end
  end
end
