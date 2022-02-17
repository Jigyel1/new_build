# frozen_string_literal: true

module Mutations
  module Projects
    class UpdatePaybackPeriod < BaseMutation
      class UpdatePaybackPeriodAttributes < Types::BaseInputObject
        argument :connection_cost_id, ID, required: true
        argument :months, Int, required: false
      end

      argument :attributes, UpdatePaybackPeriodAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(::Projects::PaybackPeriodUpdater, :project, attributes: attributes)
      end
    end
  end
end
