# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class CreateOfferAdditionalCost < BaseMutation
      class CreateOfferAdditionalCostAttributes < Types::BaseInputObject
        argument :name, GraphQL::Types::JSON, required: true
        argument :value, Float, required: true
        argument :additional_cost_type, String, required: true
      end

      argument :attributes, CreateOfferAdditionalCostAttributes, required: true
      field :offer_additional_cost, Types::AdminToolkit::OfferAdditionalCostType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::OfferAdditionalCostCreator, :offer_additional_cost, attributes: attributes.to_h)
      end
    end
  end
end
