# frozen_string_literal: true

module Projects
  class FileUpdater < BaseService
    include FileHelper
    set_callback :call, :before, :validate!

    def call
      authorize! project, to: :update?

      with_tracking do
        super { file.blob.update!(filename: attributes[:name]) }
      end
    end

    private

    def validate!
      attributes[:name].blank? && (raise "Name #{t('errors.messages.blank')}")
    end

    def activity_params
      {
        action: :attachment_file_updated,
        owner: current_user,
        trackable: file,
        parameters: { type: file.record_type.demodulize, filename: file.blob[:filename] }
      }
    end
  end
end
