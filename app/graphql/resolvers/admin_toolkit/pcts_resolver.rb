# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class PctsResolver < SearchObjectBase
      scope { ::AdminToolkit::PctValue.all }

      type [Types::AdminToolkit::PctValueType], null: false
    end
  end
end
