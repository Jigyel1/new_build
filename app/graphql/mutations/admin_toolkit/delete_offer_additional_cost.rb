# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class DeleteOfferAdditionalCost < BaseMutation
      argument :id, ID, required: true
      field :status, Boolean, null: true

      def resolve(id:)
        resolver = ::AdminToolkit::OfferAdditionalCostDeleter.new(current_user: current_user, attributes: { id: id })
        { status: resolver.call }
      end
    end
  end
end
