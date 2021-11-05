# frozen_string_literal: true

module Users
  module ActivityHelper
    def activity_params(action, parameters = {})
      {
        action: action,
        owner: current_user,
        recipient: user,
        trackable: user,
        parameters: parameters
      }
    end
  end
end
