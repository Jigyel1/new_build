# frozen_string_literal: true

module Projects
  class LabelsUpdater < BaseService
    set_callback :call, :before, :validate!

    def label_group
      @label_group ||= ::Projects::LabelGroup.find(attributes[:id])
    end

    def call
      authorize! project, to: :update?, with: ProjectPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        super do
          label_group.label_list = attributes[:label_list]
          label_group.save!
        end

        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def validate!
      return unless label_group.system_generated?

      raise(t('projects.label_group.system_generated'))
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_labels_updated,
        owner: current_user,
        trackable: label_group,
        parameters: attributes.except(:id)
      }
    end

    def project
      @project ||= label_group.project
    end
  end
end
