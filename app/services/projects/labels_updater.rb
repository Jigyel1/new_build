# frozen_string_literal: true

module Projects
  class LabelsUpdater < BaseService
    include ProjectLabelHelper

    set_callback :call, :before, :validate!

    def label_group
      @label_group ||= ::Projects::LabelGroup.find(attributes[:id])
    end

    def call
      authorize! project, to: :update?

      with_tracking do
        super do
          added_project_label
          label_group.label_list = attributes[:label_list]
          label_group.save!
        end
      end
    end

    private

    def validate!
      return unless label_group.system_generated?

      raise(t('projects.label_group.system_generated'))
    end

    def activity_params
      {
        action: :labels_updated,
        owner: current_user,
        trackable: label_group,
        parameters: {
          label_list: label_group.label_list.join(', '),
          project_name: project.name,
          status: label_group.project_status
        }
      }
    end

    def project
      @project ||= label_group.project
    end
  end
end
