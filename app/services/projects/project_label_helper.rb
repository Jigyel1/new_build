# frozen_string_literal: true

module Projects
  module ProjectLabelHelper
    private

    def added_project_label
      return unless Projects::LabelGroup.where(system_generated: false).present?
      
      labels = Projects::LabelGroup.where(system_generated: false).find_by(project_id: project.id)
      project.update!(added_labels: labels.label_list)
    end
  end
end
