# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateOfferMarketing < BaseMutation
      class UpdateOfferMarketingAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :activity_name, GraphQL::Types::JSON, required: false
        argument :value, Float, required: false
      end

      argument :attributes, UpdateOfferMarketingAttributes, required: true
      field :offer_marketing, Types::AdminToolkit::OfferMarketingType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::OfferMarketingUpdater, :offer_marketing, attributes: attributes.to_h)
      end
    end
  end
end
