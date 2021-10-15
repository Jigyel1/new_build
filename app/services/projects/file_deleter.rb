# frozen_string_literal: true

module Projects
  class FileDeleter < BaseService
    include FileHelper

    def call
      authorize! project, to: :update?
      file.destroy!
    end
  end
end
