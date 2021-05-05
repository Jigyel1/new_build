# frozen_string_literal: true

module Activities
  class ForOwner < BaseService
    include ActivityHelper

    def call
      case activity.verb.to_sym
      when :status_updated
        t(
          "activities.#{activity.trackable_type.downcase}.status_updated.owner",
          recipient_email: activity.recipient.email,
          active: parameters.active
        )
      end
    end
  end
end
