module Mutations
  module Projects
    class ExcelCreate < BaseMutation
      argument :file, ApolloUploadServer::Upload, required: true
      field :status, Boolean, null: true

      def resolve(file:)
        ProjectImporter.call(current_user: current_user, file: file)

        { status: true }
      end
    end
  end
end
