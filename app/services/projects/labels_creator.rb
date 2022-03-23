# frozen_string_literal: true

module Projects
  class LabelsCreator < BaseService
    def call
      authorize! project, to: :update?

      with_tracking do
        label_group.label_list = attributes[:label_list]
        label_group.save!
      end
    end

    def label_group
      @label_group ||= project.label_groups.find_or_create_by!(label_group_id: attributes[:label_group_id])
    end

    private

    def project
      @project ||= Project.find(attributes[:project_id])
    end

    def activity_params
      {
        action: :labels_created,
        owner: current_user,
        trackable: label_group,
        parameters: {
          label_list: label_group.label_list.join(', '),
          project_name: project.name,
          status: label_group.project_status
        }
      }
    end
  end
end
