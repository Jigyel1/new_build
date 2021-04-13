# frozen_string_literal: true

module Resolvers
  class Departments < BaseResolver
    scope { Profile::VALID_DEPARTMENTS }

    type [String], null: false
  end
end
