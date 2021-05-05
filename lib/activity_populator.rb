# Activity creation is a secondary action. We will only raise a rollbar
# error for devs to debug and not show to the user.
class ActivityPopulator
  include Assigner
  attr_accessor :activity_type, :owner, :recipient, :verb, :parameters

  def initialize(attributes = {})
    assign_attributes(attributes)
  end

  def log_activity
    owner.activities.create(
      recipient: recipient,
      verb: verb,
      trackable_type: 'User',
      parameters: parameters || {},
      log_data: {
        owner_email: owner.email,
        recipient_email: recipient.email
      }
    ) || report_failure
  end

  def log_involvement
    recipient.involvements.create(
      owner: owner,
      verb: verb,
      trackable_type: 'User',
      parameters: parameters || {},
      log_data: {
        owner_email: owner.email,
        recipient_email: recipient.email
      }
    ) || report_failure
  end

  private

  def report_failure
    byebug
    # Rollbar.error(errors)
  end
end
