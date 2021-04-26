# frozen_string_literal: true

User = Telco::Uam::User

User.class_eval do
  include Discard::Model

  # Since user is derived from the engine(telco-uam), it has no knowledge
  # of it's associations. To support `strict_loading_by_default` we have to add custom
  # preloading of associations, thereby making the code a bit more messy,
  # which I feel is not worth the slight benefit achieved.
  self.strict_loading_by_default = false

  belongs_to :role, inverse_of: :users
  has_one :profile, inverse_of: :user, dependent: :destroy
  has_one :address, as: :addressable, inverse_of: :addressable, dependent: :destroy

  validates :profile, presence: true

  default_scope { kept }

  accepts_nested_attributes_for :profile, :address, allow_destroy: true

  delegate :salutation, :name, :lastname, :firstname, to: :profile
  delegate :permissions, to: :role

  has_logidze

  def invite!(invited_by = nil, options = {})
    DomainValidator.new(email).run

    super
  end
end
