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
        resolver = ::AdminToolkit::KamInvestorUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { kam_investor: resolver.kam_investor }
      end
    end
  end
end
