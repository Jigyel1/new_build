# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class DeleteOfferContent < BaseMutation
      argument :id, ID, required: true
      field :status, Boolean, null: true

      def resolve(id:)
        resolver = ::AdminToolkit::OfferContentDeleter.new(current_user: current_user, attributes: { id: id })
        { status: resolver.call }
      end
    end
  end
end
