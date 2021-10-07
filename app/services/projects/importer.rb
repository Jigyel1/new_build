# frozen_string_literal: true

module Projects
  class Importer < BaseService
    attr_accessor :file

    def call
      authorize! Project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        ProjectsImporter.call(current_user: current_user, input: file)

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_imported,
        owner: current_user,
        trackable_type: 'Projects',
        parameters: {
          filename: file.original_filename
        }
      }
    end
  end
end
