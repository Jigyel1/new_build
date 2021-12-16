# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class CreateOfferAdditionalCost < BaseMutation
      class CreateOfferAdditionalCostAttributes < Types::BaseInputObject
        argument :name, GraphQL::Types::JSON, required: false
        argument :value, Float, required: false
        argument :additional_cost_type, String, required: false
      end

      argument :attributes, CreateOfferAdditionalCostAttributes, required: true
      field :offer_additional_cost, Types::AdminToolkit::OfferAdditionalCostType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::OfferAdditionalCostCreator, :offer_additional_cost, attributes: attributes.to_h)
      end
    end
  end
end
