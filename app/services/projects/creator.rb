# frozen_string_literal: true

require_relative '../../../app/models/admin_toolkit'

module Projects
  class Creator < BaseService
    attr_reader :project

    def call
      authorize! Project, to: :create?, with: ProjectPolicy
      with_tracking(activity_id = SecureRandom.uuid) do
        @project = ::Project.new(attributes)
        project.save!
        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_created,
        owner: current_user,
        trackable: project,
        parameters: attributes
      }
    end
  end
end
