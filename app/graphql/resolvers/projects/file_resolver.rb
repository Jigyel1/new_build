# frozen_string_literal: true

module Resolvers
  module Projects
    class FileResolver < BaseResolver
      argument :id, ID, required: true
      type Types::Projects::FileType, null: true

      def resolve(id:)
        ActiveStorage::Attachment.find(id)
      end
    end
  end
end
