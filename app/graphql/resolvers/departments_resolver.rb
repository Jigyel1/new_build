# frozen_string_literal: true

module Resolvers
  class DepartmentsResolver < SearchObjectBase
    scope { Profile::VALID_DEPARTMENTS }

    type [String], null: false
  end
end
