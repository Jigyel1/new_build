# frozen_string_literal: true

module Mutations
  class ImportProject < BaseMutation
    argument :file, ApolloUploadServer::Upload, required: true
    field :status, Boolean, null: true

    def resolve(file:)
      Projects::Importer.new(current_user: current_user, file: file).call

      { status: true }
    end
  end
end
