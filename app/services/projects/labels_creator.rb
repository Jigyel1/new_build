# frozen_string_literal: true

module Projects
  class LabelsCreator < BaseService
    def label_group
      @label_group ||= project.label_groups.find_or_create_by!(label_group_id: attributes[:label_group_id])
    end

    def project
      @project ||= Project.find(attributes[:project_id])
    end

    def call
      authorize! project, to: :update?, with: ProjectPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        label_group.label_list = attributes[:labelList]
        label_group.save!

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :label_group_created,
        owner: current_user,
        trackable: label_group,
        parameters: attributes.except(:id)
      }
    end
  end
end
