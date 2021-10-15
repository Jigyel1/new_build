# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class CreateCompetition < BaseMutation
      class CreateCompetitionAttributes < Types::BaseInputObject
        include Concerns::Competition
      end

      argument :attributes, CreateCompetitionAttributes, required: true
      field :competition, Types::AdminToolkit::CompetitionType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::CompetitionCreator, :competition, attributes: attributes.to_h)
      end
    end
  end
end
