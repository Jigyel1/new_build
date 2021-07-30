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
        resolver = ::AdminToolkit::KamInvestorCreator.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { kam_investor: resolver.kam_investor }
      end
    end
  end
end
