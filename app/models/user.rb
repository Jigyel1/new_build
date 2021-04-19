# frozen_string_literal: true

User = Telco::Uam::User

User.class_eval do
  include Discard::Model

  self.strict_loading_by_default = false # TODO: remove this!

  belongs_to :role, inverse_of: :users
  has_one :profile, inverse_of: :user, strict_loading: false, dependent: :destroy
  has_one :address, as: :addressable, inverse_of: :addressable, dependent: :destroy

  validates :profile, presence: true

  default_scope { kept }

  accepts_nested_attributes_for :profile, :address, allow_destroy: true

  delegate :salutation, :lastname, :firstname, to: :profile

  def invite!(invited_by = nil, options = {})
    DomainValidator.new(email).run

    super
  end
end
