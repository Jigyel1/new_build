# frozen_string_literal: true

module Resolvers
  class Departments < SearchObjectBase
    scope { Profile::VALID_DEPARTMENTS }

    type [String], null: false
  end
end
