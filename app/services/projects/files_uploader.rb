# frozen_string_literal: true

require 'active_storage'

module Projects
  class FilesUploader < BaseService
    include FileHelper
    delegate :files, to: :attachable

    def call
      authorize! project, to: :update?

      attachable.files.attach(
        attributes[:files].map { |file| to_attachables(file) }
      )
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
  end
end
