# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class LabelsResolver < SearchObjectBase
      scope { ::AdminToolkit::LabelGroup.all }

      type [Types::AdminToolkit::LabelGroupType], null: false
    end
  end
end
