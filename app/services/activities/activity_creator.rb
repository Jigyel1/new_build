# frozen_string_literal: true

# Activity creation is a secondary action. Primary action eg. `status_update`, `role_change` etc
# should not be affected if the activity creation fails.
# We will only raise a rollbar error for devs to debug and not show to the end user.
#
# Also, When you have more recipients for an activity. For eg.
#    #=> User A, B, C were added to the Project X by User D
# where A, B, C are your recipients, create an activity for each recipient.
#
module Activities
  class ActivityCreator < BaseActivity
    attr_accessor :activity_id, :owner, :recipient, :action, :parameters, :trackable

    def call
      owner.activities.create!(
        id: activity_id || SecureRandom.uuid,
        recipient: recipient,
        action: action,
        trackable: trackable,
        log_data: {
          owner_email: owner.email,
          recipient_email: recipient.try(:email),
          parameters: parameters
        }
      ).then { |activity| activity.persisted? ? activity : log_error(activity) }
    end

    private

    def log_error(activity)
      byebug
      Rollbar.error(activity.errors.full_messages) if Rails.env.production?

      Rails.logger.error(activity.errors.full_messages)
    end
  end
end
