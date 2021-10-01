# frozen_string_literal: true

module Projects
  class FileUpdater < BaseService
    include FileHelper
    set_callback :call, :before, :validate!

    def call
      authorize! project, to: :update?

      super { file.blob.update!(filename: attributes[:name]) }
    end

    private

    def validate!
      attributes[:name].blank? && (raise "Name #{t('errors.messages.blank')}")
    end
  end
end
