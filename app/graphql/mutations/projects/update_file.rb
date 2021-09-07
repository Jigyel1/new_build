# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateFile < BaseMutation
      class UpdateFileAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :name, String, required: true
      end

      argument :attributes, UpdateFileAttributes, required: true
      field :file, Types::Projects::FileType, null: true

      def resolve(attributes:)
        super(::Projects::FileUpdater, :file, attributes: attributes)
      end
    end
  end
end
