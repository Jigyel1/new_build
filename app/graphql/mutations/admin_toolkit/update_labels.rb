# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateLabels < BaseMutation
      class UpdateLabelAttributes < Types::BaseInputObject
        argument :label_group_id, ID, required: true
        argument :labelList, String, required: true
      end

      argument :attributes, UpdateLabelAttributes, required: true
      field :label_group, Types::AdminToolkit::LabelGroupType, null: true

      def resolve(attributes:)
        resolver = ::AdminToolkit::LabelsUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call

        { label_group: resolver.label_group }
      end
    end
  end
end
