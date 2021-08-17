# frozen_string_literal: true

# require_relative '../../../app/models/admin_toolkit'

module Projects
  class Updater < BaseService
    attr_reader :project

    def call
      authorize! Project, to: :update?, with: ProjectPolicy
      with_tracking(activity_id = SecureRandom.uuid) do
        @project = ::Project.find(attributes.delete(:id))
        project.update!(attributes)
        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_updated,
        owner: current_user,
        trackable: project,
        parameters: attributes
      }
    end
  end
end
