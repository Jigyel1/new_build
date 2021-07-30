# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateKamRegions < BaseMutation
      class UpdateKamRegionsAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :kam_id, ID, required: true
      end

      argument :attributes, [UpdateKamRegionsAttributes], required: true
      field :status, Boolean, null: true

      def resolve(attributes:)
        ::AdminToolkit::KamRegionsUpdater.new(current_user: current_user, attributes: attributes.map(&:to_h)).call
        { status: true }
      end
    end
  end
end
