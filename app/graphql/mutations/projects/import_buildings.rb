# frozen_string_literal: true

module Mutations
  module Projects
    class ImportBuildings < BaseMutation
      argument :file, ApolloUploadServer::Upload, required: true
      field :status, Boolean, null: true

      def resolve(file:)
        ::Projects::BuildingsImporter.new(current_user: current_user, file: file).call

        { status: true }
      end
    end
  end
end
