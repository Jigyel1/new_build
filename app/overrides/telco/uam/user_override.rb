# frozen_string_literal: true

User = Telco::Uam::User

module Telco
  module Uam
    class User
      include Discard::Model
      include LogidzeWrapper

      # Since user is derived from the engine(telco-uam), it has no knowledge
      # of it's associations. To support `strict_loading_by_default` we have to add custom
      # preloading of associations, thereby making the code a bit more messy,
      # which I feel is not worth the slight benefit achieved.
      self.strict_loading_by_default = false

      belongs_to :role, counter_cache: true
      has_one :profile, inverse_of: :user, dependent: :destroy
      has_one :address, as: :addressable, inverse_of: :addressable, dependent: :destroy

      has_many :activities, foreign_key: :owner_id, dependent: :destroy
      has_many :involvements, foreign_key: :recipient_id, class_name: 'Activity', dependent: :destroy

      has_one_attached :activity_download

      validates :profile, presence: true

      default_scope { kept }

      accepts_nested_attributes_for :profile, :address, allow_destroy: true

      delegate :salutation, :name, :lastname, :firstname, to: :profile
      delegate :id, to: :profile, prefix: true
      delegate :id, to: :address, prefix: true, allow_nil: true
      delegate :permissions, :admin?, to: :role
      delegate :name, to: :role, prefix: true

      # Updates provider & uid for the user.
      #
      # @param auth [Hash] - which contains uid & provider details
      # @return [<User>] - resource instance
      def self.from_omniauth(auth)
        user_creator = Users::UserCreator.new(auth: auth)
        user_creator.call
        user_creator.user
      end

      # Users will be logged in through Azure B2C so password won't be necessary.
      def password_required?
        false
      end

      has_logidze

      def invite!(invited_by = nil, options = {})
        Users::UserInviter.new(current_user: Current.current_user, user: self).call { super }
      end
    end
  end
end