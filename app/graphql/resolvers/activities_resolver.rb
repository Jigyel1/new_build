# frozen_string_literal: true

module Resolvers
  class ActivitiesResolver < SearchObjectBase
    include Activities::ActivityHelper

    scope { scoped_activities }

    type Types::ActivityConnectionType, null: false

    option :emails, type: [String], with: :apply_email_filter
    option :actions, type: [String], with: :apply_action_filter
    option :dates, type: [String], with: :apply_date_filter, description: <<~DESC
      Send one or two dates in the dates array. If only one date is sent, logs created on that date will
      be returned. Else the logs between the first two dates will be returned. Date format expected -> '2021-05-06'
    DESC
    option :query, type: String, with: :apply_search
  end
end
