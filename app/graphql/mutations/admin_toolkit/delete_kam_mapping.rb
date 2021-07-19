# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class DeleteKamMapping < BaseMutation
      argument :id, ID, required: true
      field :status, Boolean, null: true

      def resolve(id:)
        ::AdminToolkit::KamMappingDeleter.new(current_user: current_user, attributes: { id: id }).call
        { status: true }
      end
    end
  end
end
