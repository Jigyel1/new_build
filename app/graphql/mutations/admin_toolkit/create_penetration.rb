# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class CreatePenetration < BaseMutation
      class CreatePenetrationCompetitionAttributes < Types::BaseInputObject
        argument :competition_id, ID, required: false
      end

      class CreatePenetrationAttributes < Types::BaseInputObject
        include Concerns::Penetration

        argument(
          :penetration_competitions,
          [CreatePenetrationCompetitionAttributes],
          required: false,
          as: :penetration_competitions_attributes
        )
      end

      argument :attributes, CreatePenetrationAttributes, required: true
      field :penetration, Types::AdminToolkit::PenetrationType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::PenetrationCreator, :penetration, attributes: attributes.to_h)
      end
    end
  end
end
