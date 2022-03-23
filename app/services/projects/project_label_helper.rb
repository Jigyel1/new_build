# frozen_string_literal: true

module Projects
  module ProjectLabelHelper
    private

    def added_project_label
      labels = Projects::LabelGroup.where(system_generated: false).find_by(project_id: project.id).label_list
      project.update!(added_labels: labels)
    end
  end
end
