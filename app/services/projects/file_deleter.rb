# frozen_string_literal: true

module Projects
  class FileDeleter < BaseService
    include FileHelper

    def call
      authorize! project, to: :update?

      with_tracking { file.destroy! }
    end

    def activity_params
      {
        action: :attachment_file_deleted,
        owner: current_user,
        trackable: file,
        parameters: { type: file.record_type.demodulize, filename: file.blob[:filename] }
      }
    end
  end
end
