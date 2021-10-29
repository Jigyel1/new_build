# frozen_string_literal: true

module Projects
  class InchargeUnassigner < BaseService
    def call
      authorize! project, to: :unassign_incharge?

      with_tracking(activity_id = SecureRandom.uuid) do # rubocop:disable Lint/UselessAssignment
        project.update!(incharge_id: nil)

        # TODO: @Jigyel - FYA
        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def project
      @project ||= Project.find(attributes[:id])
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :incharge_unassigned,
        owner: current_user,
        trackable: project,
        parameters: attributes
      }
    end
  end
end