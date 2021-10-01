# frozen_string_literal: true

module Projects
  class CategoryUpdater < BaseService
    def call
      authorize! project, to: :update?, with: ProjectPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        project.update!(
          category: attributes[:category],
          system_sorted_category: false
        )
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def project
      @_project ||= Project.find(attributes[:project_id])
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_category_updated,
        owner: current_user,
        trackable: project,
        parameters: attributes
      }
    end
  end
end
