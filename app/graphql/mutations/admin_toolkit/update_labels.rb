# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateLabels < BaseMutation
      class UpdateLabelAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :labelList, String, required: true
      end

      argument :attributes, UpdateLabelAttributes, required: true
      field :label_group, Types::AdminToolkit::LabelGroupType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::LabelsUpdater, :label_group, attributes: attributes.to_h)
      end
    end
  end
end
