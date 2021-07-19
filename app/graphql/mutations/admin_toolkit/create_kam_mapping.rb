# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class CreateKamMapping < BaseMutation
      class CreateKamMappingAttributes < Types::BaseInputObject
        include CommonAttributes::KamMapping
      end

      argument :attributes, CreateKamMappingAttributes, required: true
      field :kam_mapping, Types::AdminToolkit::KamMappingType, null: true

      def resolve(attributes:)
        resolver = ::AdminToolkit::KamMappingCreator.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call

        { kam_mapping: resolver.kam_mapping }
      end
    end
  end
end
