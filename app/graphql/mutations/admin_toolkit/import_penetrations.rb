# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class ImportPenetrations < BaseMutation
      argument :file, ApolloUploadServer::Upload, required: true
      field :status, Boolean, null: true

      def resolve(file:)
        ::AdminToolkit::PenetrationsImporter.new(current_user: current_user, file: file).call

        { status: true }
      end
    end
  end
end
