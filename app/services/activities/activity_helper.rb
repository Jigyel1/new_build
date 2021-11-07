# frozen_string_literal: true

# Any change made in this file should be reflected in
#   `app/services/activities/activity_exporter.rb`
#
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

    def apply_user_filter(scope, value)
      scope.where(owner_id: value).or(scope.where(recipient_id: value))
    end

    def apply_action_filter(scope, value)
      scope.where(action: value)
    end

    # @param scope [<Activity>] Filtered activities
    # @param value [Array<Datetime>] StartDate and EndDate in UTC format => ["2021-06-02T18:00:00.000Z"]
    # @return [ActiveRecord::Relation] The activities
    def apply_date_filter(scope, value)
      start_date, end_date = value.map { |time_str| time_str.to_datetime.in_time_zone(Current.time_zone) }
      end_date ||= start_date

      scope.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end

    def apply_search(scope, value)
      scope.where('action iLIKE :value OR log_data iLIKE :value', value: "%#{value}%")
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
