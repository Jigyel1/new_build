class Activity < ApplicationRecord
  belongs_to :owner, class_name: 'Telco::Uam::User'
  belongs_to :recipient, class_name: 'Telco::Uam::User'

  # project, news, events etc.
  # optional true when the activity involves just the users.
  belongs_to :trackable, polymorphic: true, optional: true

  validates :verb, presence: :true
end
