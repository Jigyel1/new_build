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
    attr_accessor :activity_id, :owner, :recipient, :action, :parameters, :trackable,
                  :trackable_type

    def call
      owner.activities
           .create!(activity_params.merge(trackable_params))
           .then { |activity| activity.persisted? ? activity : log_error(activity) }
    end

    private

    def activity_params
      {
        id: activity_id || SecureRandom.uuid,
        recipient: recipient,
        action: action,
        log_data: {
          owner_email: owner.email,
          recipient_email: recipient.try(:email),
          parameters: parameters
        }
      }
    end

    # <tt>trackable</tt> can be nil for bulk actions, like <tt>buildings_import</tt>
    # or <tt>projects_import</tt>. In such cases just select the <tt>trackable_type</tt>
    # for logging the activity. <tt>trackable_type</tt> will always be present.
    def trackable_params
      trackable ? { trackable: trackable } : { trackable_type: trackable_type }
    end

    def log_error(activity)
      Rollbar.error(activity.errors.full_messages) if Rails.env.production?

      Rails.logger.error(activity.errors.full_messages)
    end
  end
end
