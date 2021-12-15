# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateOfferPrice < BaseMutation
      class UpdateOfferPriceAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :min_apartments, Integer, required: false
        argument :max_apartments, Integer, required: false
        argument :name, GraphQL::Types::JSON, required: false
        argument :value, BigDecimal, required: false
      end

      argument :attributes, UpdateOfferPriceAttributes, required: true
      field :offer_content, Types::AdminToolkit::OfferPriceType, null: true

      def resolve(attributes:)
        # super(::AdminToolkit::OfferContentUpdater, :offer_content, attributes: attributes.to_h)
      end
    end
  end
end
