# frozen_string_literal: true

module Projects
  class InchargeUnassigner < BaseService
    def call
      authorize! project, to: :unassign_incharge?

      with_tracking(activity_id = SecureRandom.uuid) do
        project.update!(incharge_id: nil)
        Activities::ActivityCreator.new(activity_id: activity_id, **activity_params).call
      end
    end

    def project
      @project ||= Project.find(attributes[:id])
    end

    private

    def activity_params
      {
        action: :incharge_unassigned,
        owner: current_user,
        trackable: project,
        parameters: { project_name: project.name }
      }
    end
  end
end
