# frozen_string_literal: true

module Resolvers
  class DepartmentsResolver < SearchObjectBase
    scope { Rails.application.config.user_departments }

    type [String], null: false
  end
end
