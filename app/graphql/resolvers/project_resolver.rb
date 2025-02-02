# frozen_string_literal: true

module Resolvers
  class ProjectResolver < BaseResolver
    argument :id, ID, required: true
    type Types::ProjectType, null: true

    def resolve(id:)
      Project.find(id).tap do |project|
        update_assignee(project)
      end
    end

    private

    # If the project is not yet assigned to a user and if the current user is from the
    # NBO team, set that as the project's assignee.
    def update_assignee(project)
      return if skip_assignment?(project)

      project.update_column(:assignee_id, current_user.id)
    end

    # Skip if the project is already assigned to a user or the current user is not from the NBO Team.
    def skip_assignment?(project)
      project.assignee || !current_user.nbo_team?
    end
  end
end
