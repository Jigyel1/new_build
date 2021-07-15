# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class FootprintsResolver < SearchObjectBase
      scope { ::AdminToolkit::FootprintValue.all }

      type [Types::AdminToolkit::FootprintValueType], null: false
    end
  end
end
