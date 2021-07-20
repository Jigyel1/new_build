# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class CreateCompetition < BaseMutation
      class CreateCompetitionAttributes < Types::BaseInputObject
        include CommonAttributes::Competition
      end

      argument :attributes, CreateCompetitionAttributes, required: true
      field :competition, Types::AdminToolkit::CompetitionType, null: true

      def resolve(attributes:)
        resolver = ::AdminToolkit::CompetitionCreator.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { competition: resolver.competition }
      end
    end
  end
end
