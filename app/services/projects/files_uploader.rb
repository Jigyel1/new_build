# frozen_string_literal: true

require 'active_storage'

module Projects
  class FilesUploader < BaseService
    include FileHelper
    delegate :files, to: :attachable

    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        attachable.files.attach(
          attributes[:files].map { |file| to_attachables(file) }
        )
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def attachable
      @attachable ||= attributes[:attachable_type]
                      .constantize
                      .find(attributes[:attachable_id])
    end

    private

    # `ActionDispatch::UploadedFile` has to be converted to attachable for ActiveStorage
    # to properly attach it.
    def to_attachables(file)
      ActionDispatch::Http::UploadedFile.new(
        filename: file.original_filename,
        type: file.content_type,
        head: file.headers,
        tempfile: file.tempfile
      )
    end

    # `Attachable` can either be a `project` or a `building`.
    # If its a `project`, return that. Else, it will be a building in which case,
    # you return `attachable.project`
    def project
      attachable.is_a?(Project) ? attachable : attachable.project
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :file_uploaded,
        owner: current_user,
        trackable: attachable,
        parameters: {
          filename: attributes[:files][0].original_filename
        }
      }
    end
  end
end
