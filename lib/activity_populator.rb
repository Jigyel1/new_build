# frozen_string_literal: true

# Activity creation is a secondary action. We will only raise a rollbar
# error for devs to debug and not show to the end user.
class ActivityPopulator
  include Assigner
  attr_accessor :activity_id, :activity_type, :owner, :recipient, :verb, :parameters

  def initialize(attributes = {})
    assign_attributes(attributes)
  end

  def call # rubocop:disable Metrics/SeliseMethodLength
    owner.activities.create!(
      id: activity_id || SecureRandom.uuid,
      recipient: recipient,
      verb: verb,
      trackable_type: 'User',
      log_data: {
        owner_email: owner.email,
        recipient_email: recipient.email,
        parameters: parameters
      }
    ).then { |activity| activity.persisted? ? activity : (puts activity.errors.full_messages) } # rubocop:disable Rails/Output
  end
end
# Rollbar.error(activity.errors.full_messages)
