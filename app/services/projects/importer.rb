# frozen_string_literal: true

module Projects
  class Importer < BaseService
    attr_accessor :file

    def call
      authorize! Project, to: :import?, with: ProjectPolicy
      with_tracking(activity_id = SecureRandom.uuid) do
        ProjectsImporter.call(current_user: current_user, input: file)
        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    # TODO - trackable - Project?
    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_imported,
        owner: current_user,
        # trackable: project,
        parameters: attributes
      }
    end
  end
end
