# frozen_string_literal: true

module Resolvers
  class ActivityActionsResolver < SearchObjectBase
    scope { Rails.application.config.activity_actions }

    type GraphQL::Types::JSON, null: false
  end
end
