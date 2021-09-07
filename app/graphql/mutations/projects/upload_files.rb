# frozen_string_literal: true

module Mutations
  module Projects
    class UploadFiles < BaseMutation
      class UploadFilesAttributes < Types::BaseInputObject
      argument :attachable_id, ID, required: true
      argument :attachable_type, String, required: true, description: <<~DESC
          If project, send "Project". If building, send the value as "Projects::Building"
      DESC
      argument :files, [ApolloUploadServer::Upload], required: true
      end

      argument :attributes, UploadFilesAttributes, required: true
      field :files, [Types::Projects::FileType], null: true

      def resolve(attributes:)
        super(::Projects::FilesUploader, :files, attributes: attributes)
      end
    end
  end
end
