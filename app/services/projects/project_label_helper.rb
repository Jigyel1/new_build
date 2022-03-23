# frozen_string_literal: true

module Projects
  module ProjectLabelHelper
    private

    def added_project_label
      labels = Projects::LabelGroup.where(system_generated: false)&.find_by(project_id: project.id)
      return if labels.nil?

      project.added_labels = labels.label_list
      project.save!
    end
  end
end
