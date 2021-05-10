# frozen_string_literal: true

module Activities
  module ActivityHelper
    def scoped_activities
      if current_user.admin?
        Activity.all
      else
        Activity.where(owner_id: current_user.id).or(
          Activity.where(recipient_id: current_user.id)
        )
      end
    end

    def apply_email_filter(scope, value)
      scope.where(
        "log_data->'owner_email' ?| array[:value] OR log_data->'recipient_email' ?| array[:value]",
        value: value
      )
    end

    def apply_action_filter(scope, value)
      scope.where(action: value)
    end

    def apply_date_filter(scope, value)
      start_date, end_date = value.map(&:to_date)
      end_date ||= start_date

      scope.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end

    def apply_search(scope, value)
      query = <<~QUERY.squish
        action iLIKE :value OR
        log_data ->> 'recipient_email' iLIKE :value OR
        log_data ->> 'owner_email' iLIKE :value OR
        log_data -> 'parameters' ->> 'role' iLIKE :value OR
        log_data -> 'parameters' ->> 'active' iLIKE :value OR
        log_data -> 'parameters' ? :key
      QUERY

      scope.where(query, key: value, value: "%#{value}%")
    end

    def display_text
      ::Activities::ResponseFormatter.new(
        current_user: current_user,
        attributes: { activity: object, user_type: activity_user }
      ).call
    end

    private

    def activity_user
      case current_user.id
      when object.owner_id then 'owner'
      when object.recipient_id then 'recipient'
      else 'others'
      end
    end

    def activity
      @activity ||= attributes[:activity]
    end

    def log_data
      @log_data ||= RecursiveOpenStruct.new(activity.log_data)
    end

    def parameters
      @parameters ||= log_data.parameters
    end
  end
end
