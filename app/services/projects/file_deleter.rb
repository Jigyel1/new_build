# frozen_string_literal: true

module Projects
  class FileDeleter < BaseService
    include FileHelper

    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        file.destroy!
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :attachment_file_deleted,
        owner: current_user,
        trackable: file,
        parameters: { type: file.record_type.demodulize, filename: file.blob[:filename] }
      }
    end
  end
end