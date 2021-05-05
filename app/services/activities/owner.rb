module Activities
  class Owner < BaseService
    include ActivityHelper

    def call
      case activity.verb.to_sym
      when :status_updated
        t(
          "activities.#{activity.trackable_type.downcase}.status_updated.owner",
          owner_email: current_user.email,
          active: parameters.active
        )
      end
    end
  end
end
