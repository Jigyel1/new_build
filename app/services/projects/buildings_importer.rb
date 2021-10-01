# frozen_string_literal: true

module Projects
  class BuildingsImporter < BaseService
    attr_accessor :file

    include FileHelper

    def call
      authorize! Project, to: :import?, with: ProjectPolicy
      with_tracking(activity_id = SecureRandom.uuid) do
        ::BuildingsImporter.call(current_user: current_user, input: file)
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      binding.pry
      {
        activity_id: activity_id,
        action: :buildings_imported,
        owner: current_user,
        trackable: attachable,
        parameters: file
      }
    end
  end
end
