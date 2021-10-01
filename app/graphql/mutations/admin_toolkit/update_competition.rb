# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateCompetition < BaseMutation
      class UpdateCompetitionAttributes < Types::BaseInputObject
        include Concerns::Competition

        argument :id, ID, required: true
      end

      argument :attributes, UpdateCompetitionAttributes, required: true
      field :competition, Types::AdminToolkit::CompetitionType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::CompetitionUpdater, :competition, attributes: attributes.to_h)
      end
    end
  end
end
