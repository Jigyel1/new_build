# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateKamMapping < BaseMutation
      class UpdateKamMappingAttributes < Types::BaseInputObject
        include CommonAttributes::KamMapping

        argument :id, ID, required: true
      end

      argument :attributes, UpdateKamMappingAttributes, required: true
      field :kam_mapping, Types::AdminToolkit::KamMappingType, null: true

      def resolve(attributes:)
        resolver = ::AdminToolkit::KamMappingUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call

        { kam_mapping: resolver.kam_mapping }
      end
    end
  end
end
