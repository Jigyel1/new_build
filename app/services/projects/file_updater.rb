# frozen_string_literal: true

module Projects
  class FileUpdater < BaseService
    include FileHelper
    set_callback :call, :before, :validate!

    def call
      authorize! project, to: :update?, with: ProjectPolicy
      with_tracking(activity_id = SecureRandom.uuid, transaction: true) do
        super { file.blob.update!(filename: attributes[:name]) }

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :attachment_file_updated,
        owner: current_user,
        trackable: file,
        parameters: attributes
      }
    end

    private

    def validate!
      attributes[:name].blank? && (raise "Name #{t('errors.messages.blank')}")
    end
  end
end
