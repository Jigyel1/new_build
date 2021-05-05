# Activity creation is a secondary action. We will only raise a rollbar
# error for devs to debug and not show to the end user.
class ActivityPopulator
  include Assigner
  attr_accessor :activity_type, :owner, :recipient, :verb, :parameters

  def initialize(attributes = {})
    assign_attributes(attributes)
  end

  def call
    activity = owner.activities.create(
      recipient: recipient,
      verb: verb,
      trackable_type: 'User',
      log_data: {
        owner_email: owner.email,
        recipient_email: recipient.email,
        parameters: parameters || {}
      }
    )
    activity || Rollbar.error(activity.errors.full_messages)
  end
end
