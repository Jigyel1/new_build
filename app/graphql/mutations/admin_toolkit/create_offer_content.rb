# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class CreateOfferContent < BaseMutation
      class CreateOfferContentAttributes < Types::BaseInputObject
        argument :title, GraphQL::Types::JSON, required: true
        argument :content, GraphQL::Types::JSON, required: true
      end

      argument :attributes, CreateOfferContentAttributes, required: true
      field :offer_content, Types::AdminToolkit::OfferContentType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::OfferContentCreator, :offer_content, attributes: attributes.to_h)
      end
    end
  end
end
