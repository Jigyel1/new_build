# frozen_string_literal: true

module Projects
  class Destination
    def write(row)
      project = Project.find_or_initialize_by(external_id: row.delete(:external_id))
      return if project.persisted?

      project.assign_attributes(row)
      project.save!
    end
  end
end
