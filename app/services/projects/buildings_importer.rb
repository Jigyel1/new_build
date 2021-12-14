# frozen_string_literal: true

module Projects
  class BuildingsImporter < BaseService
    attr_accessor :file

    def call
      authorize! Project, to: :import?

      with_tracking { ::BuildingsImporter.call(current_user: current_user, input: file) }
    end

    private

    def activity_params
      {
        action: :building_imported,
        owner: current_user,
        trackable_type: 'Projects::Building',
        parameters: { filename: file.original_filename }
      }
    end
  end
end
