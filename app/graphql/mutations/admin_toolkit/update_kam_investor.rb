# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateKamInvestor < BaseMutation
      class UpdateKamInvestorAttributes < Types::BaseInputObject
        include Concerns::KamInvestor

        argument :id, ID, required: true
      end

      argument :attributes, UpdateKamInvestorAttributes, required: true
      field :kam_investor, Types::AdminToolkit::KamInvestorType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::KamInvestorUpdater, :kam_investor, attributes: attributes.to_h)
      end
    end
  end
end
