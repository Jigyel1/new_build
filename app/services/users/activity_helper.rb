# frozen_string_literal: true

module Users
  module ActivityHelper
    def activity_params(activity_id, action, parameters = {})
      {
        activity_id: activity_id,
        action: action,
        owner: current_user,
        recipient: user,
        trackable: user,
        parameters: parameters
      }
    end
  end
end
