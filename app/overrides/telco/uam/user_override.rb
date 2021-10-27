# frozen_string_literal: true

User = Telco::Uam::User

module Telco
  module Uam
    class User
      include Associations::User
      include Discard::Model
      include Hooks::User
      include LogidzeWrapper

      # Since user is derived from the engine(telco-uam), it has no knowledge
      # of it's associations. To support `strict_loading_by_default` we have to add custom
      # preloading of associations, thereby making the code a bit more messy,
      # which I feel is not worth the slight benefit achieved.
      self.strict_loading_by_default = false

      validates :profile, presence: true

      default_scope { kept }

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

      def invite!(invited_by = nil, options = {})
        Users::UserInviter.new(current_user: Current.current_user, user: self).call { super }
      end

      # for `Role` enum delegations that works as
      #   `delegate :kam?, :team_expert?, :super_user?..to: :role`
      # plus for any new role added at a later point of time.
      def method_missing(method, *args, &block)
        if role.respond_to?(method)
          role.send(method, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        role.respond_to?(method) || super
      end
    end
  end
end
