# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class CostThresholdResolver < SearchObjectBase
      scope { ::AdminToolkit::CostThreshold.all }

      type [Types::AdminToolkit::CostThresholdType], null: false
    end
  end
end
