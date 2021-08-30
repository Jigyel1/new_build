# frozen_string_literal: true

module Projects
  class LabelsUpdater < BaseService
    def label_group
      @label_group ||= ::Projects::LabelGroup.find(attributes[:id])
    end

    def project
      @project ||= label_group.project
    end

    def call
      authorize! project, to: :update?, with: ProjectPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        label_group.label_list = attributes[:labelList]
        label_group.save!

        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_labels_updated,
        owner: current_user,
        trackable: project,
        parameters: attributes.except(:id)
      }
    end
  end
end
