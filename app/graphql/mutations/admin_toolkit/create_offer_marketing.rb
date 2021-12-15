# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class CreateOfferMarketing < BaseMutation
      class CreateOfferMarketingAttributes < Types::BaseInputObject
        argument :activity_name, GraphQL::Types::JSON, required: false
        argument :value, Float, required: false
      end

      argument :attributes, CreateOfferMarketingAttributes, required: true
      field :offer_marketing, Types::AdminToolkit::OfferMarketingType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::OfferMarketingCreator, :offer_marketing, attributes: attributes.to_h)
      end
    end
  end
end
