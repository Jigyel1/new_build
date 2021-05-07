# frozen_string_literal: true

module Resolvers
  class ActivitiesResolver < SearchObjectBase
    scope do
      if current_user.admin?
        Activity.all
      else
        Activity.where(owner_id: current_user.id).or(
          Activity.where(recipient_id: current_user.id)
        )
      end
    end

    type Types::ActivityConnectionType, null: false

    option :emails, type: [String], with: :apply_email_filter
    option :dates, type: [String], with: :apply_date_filter, description: <<~DESC
      Send one or two dates in the dates array. If only one date is sent, logs created on that date will
      be returned. Else the logs between the first two dates will be returned. Date format expected -> '2021-05-06'
    DESC
    option :query, type: String, with: :apply_search

    def apply_email_filter(scope, value)
      scope.where(
        "log_data->'owner_email' ?| array[:value] OR log_data->'recipient_email' ?| array[:value]",
        value: value
      )
    end

    def apply_date_filter(scope, value)
      start_date, end_date = value.map(&:to_date)
      if start_date && end_date
        scope.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
      elsif start_date
        scope.where('DATE(created_at) = :date', date: value)
      else
        scope
      end
    end

    def apply_search(scope, value)
      query = <<~QUERY.squish
        verb iLIKE :value OR
        log_data ->> 'recipient_email' iLIKE :value OR
        log_data ->> 'owner_email' iLIKE :value OR
        log_data -> 'parameters' ->> 'role' iLIKE :value OR
        log_data -> 'parameters' ->> 'active' iLIKE :value OR
        log_data -> 'parameters' ? :key
      QUERY

      scope.where(query, key: value, value: "%#{value}%")
    end
  end
end
