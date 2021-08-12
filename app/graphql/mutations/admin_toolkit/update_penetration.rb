# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdatePenetration < BaseMutation
      class UpdatePenetrationCompetitionAttributes < Types::BaseInputObject
        argument :id, ID, required: false
        argument :competition_id, ID, required: false
        argument :_destroy, Int, required: false
      end

      class UpdatePenetrationAttributes < Types::BaseInputObject
        include Concerns::Penetration

        argument :id, ID, required: true
        argument(
          :penetration_competitions,
          [UpdatePenetrationCompetitionAttributes],
          required: false,
          as: :penetration_competitions_attributes
        )
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
