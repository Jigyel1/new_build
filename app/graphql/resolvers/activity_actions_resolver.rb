# frozen_string_literal: true

module Resolvers
  class ActivityActionsResolver < SearchObjectBase
    scope { Activity::VALID_ACTIONS }

    type GraphQL::Types::JSON, null: false
  end
end
