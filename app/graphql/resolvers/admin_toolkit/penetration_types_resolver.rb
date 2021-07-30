# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class PenetrationTypesResolver < SearchObjectBase
      scope { ::AdminToolkit::Penetration.types }

      type GraphQL::Types::JSON, null: false
    end
  end
end
