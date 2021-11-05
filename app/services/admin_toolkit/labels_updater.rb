# frozen_string_literal: true

module AdminToolkit
  class LabelsUpdater < BaseService
    def label_group
      @label_group ||= AdminToolkit::LabelGroup.find(attributes[:id])
    end

    def call
      authorize! label_group, to: :update?, with: AdminToolkitPolicy

      with_tracking do
        label_group.label_list = attributes[:label_list]
        label_group.save!
      end
    end

    private

    def activity_params
      {
        action: :label_group_updated,
        owner: current_user,
        trackable: label_group,
        parameters: attributes.except(:id)
      }
    end
  end
end
