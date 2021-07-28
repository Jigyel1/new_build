# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class PenetrationTypesResolver < SearchObjectBase
      scope { ::AdminToolkit::Penetration.types.values }

      type [String], null: false
    end
  end
end
