# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateOfferContent < BaseMutation
      class UpdateOfferContentAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :title, GraphQL::Types::JSON, required: false
        argument :content, GraphQL::Types::JSON, required: false
      end

      argument :attributes, UpdateOfferContentAttributes, required: true
      field :offer_content, Types::AdminToolkit::OfferContentType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::OfferContentUpdater, :offer_content, attributes: attributes.to_h)
      end
    end
  end
end
