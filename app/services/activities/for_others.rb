# frozen_string_literal: true

module Activities
  class ForOthers < BaseService
    include ActivityHelper

    def call
      case activity.verb.to_sym
      when :status_updated
        t(
          "activities.#{activity.trackable_type.downcase}.status_updated.others",
          owner_email: activity.owner.email,
          recipient_email: activity.recipient.email,
          active: parameters.active
        )
      end
    end
  end
end
