# frozen_string_literal: true

module AdminToolkit
  class LabelsUpdater < BaseService
    def label_group
      @label_group ||= AdminToolkit::LabelGroup.find(attributes[:id])
    end

    def call
      authorize! label_group, to: :update?, with: AdminToolkitPolicy

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
        action: :label_group_updated,
        owner: current_user,
        trackable: label_group,
        parameters: attributes.except(:id)
      }
    end

    # TODO: Labels should be unique - case insensitive!
  end
end
