# frozen_string_literal: true

module Resolvers
  class ActivitiesResolver < SearchObjectBase
    scope { ::Activity.all }

    type Types::ActivityConnectionType, null: false
  end
end
