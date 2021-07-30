# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class CreatePenetration < BaseMutation
      class CreatePenetrationAttributes < Types::BaseInputObject
        include Concerns::Penetration
      end

      argument :attributes, CreatePenetrationAttributes, required: true
      field :penetration, Types::AdminToolkit::PenetrationType, null: true

      def resolve(attributes:)
        resolver = ::AdminToolkit::PenetrationCreator.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { penetration: resolver.penetration }
      end
    end
  end
end
