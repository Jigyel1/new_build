# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateCompetition < BaseMutation
      class UpdateCompetitionAttributes < Types::BaseInputObject
        include CommonAttributes::Competition

        argument :id, ID, required: true
      end

      argument :attributes, UpdateCompetitionAttributes, required: true
      field :competition, Types::AdminToolkit::CompetitionType, null: true

      def resolve(attributes:)
        resolver = ::AdminToolkit::CompetitionUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call

        { competition: resolver.competition }
      end
    end
  end
end
