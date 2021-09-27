# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class CreateKamInvestor < BaseMutation
      class CreateKamInvestorAttributes < Types::BaseInputObject
        include Concerns::KamInvestor
      end

      argument :attributes, CreateKamInvestorAttributes, required: true
      field :kam_investor, Types::AdminToolkit::KamInvestorType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::KamInvestorCreator, :kam_investor, attributes: attributes.to_h)
      end
    end
  end
end
