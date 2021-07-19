# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdatePenetration < BaseMutation
      class UpdatePenetrationAttributes < Types::BaseInputObject
        include CommonAttributes::Penetration

        argument :id, ID, required: true
      end

      argument :attributes, UpdatePenetrationAttributes, required: true
      field :penetration, Types::AdminToolkit::PenetrationType, null: true

      def resolve(attributes:)
        resolver = ::AdminToolkit::PenetrationUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call

        { penetration: resolver.penetration }
      end
    end
  end
end
