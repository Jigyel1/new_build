# frozen_string_literal: true

# When you have more recipients for an activity. For eg.
#    User A, B, C were added to the Project X by User D
# where A, B, C are your recipients, create an activity for each recipient.
#
class Activity < ApplicationRecord
  VALID_VERBS = YAML.safe_load(
    File.read(
      Rails.root.join('config/verbs.yml')
    )
  ).freeze

  include JsonAccessible

  belongs_to :owner, class_name: 'Telco::Uam::User'
  belongs_to :recipient, class_name: 'Telco::Uam::User'

  # project, news, events etc.
  # optional true when the activity involves just the users.
  belongs_to :trackable, polymorphic: true, optional: true

  validates :verb, presence: true, inclusion: VALID_VERBS
  validates :trackable_type, presence: true
  validates :log_data, activity_log: true

  default_scope { order(created_at: :desc) }
end
