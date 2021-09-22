# frozen_string_literal: true

module Mutations
  module Projects
    class SaveDraft < BaseMutation
      class SaveDraftAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :draft_version, GraphQL::Types::JSON, required: false
      end

      argument :attributes, SaveDraftAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(::Projects::DraftSaver, :project, attributes: attributes)
      end
    end
  end
end
