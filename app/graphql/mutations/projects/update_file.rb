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

      # Check out the yield option here?
      def resolve(attributes:)
        resolver = ::Projects::FileUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { file: resolver.file }
      end
    end
  end
end
