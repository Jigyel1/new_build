# frozen_string_literal: true

module Users
  class UserInviter < BaseService
    include ActivityHelper

    ALLOWED_DOMAINS = Rails.application.config.allowed_domains
    attr_accessor :user

    set_callback :call, :before, :validate!
    set_callback :call, :before, :set_action

    class UnPermittedDomainError < StandardError
      def to_s
        I18n.t(
          'domain_validator.unsupported_domain',
          domain: 'domain'.pluralize(ALLOWED_DOMAINS.size),
          domains: ALLOWED_DOMAINS.to_sentence
        )
      end
    end

    def call
      run_callbacks :call do
        with_tracking(activity_id = SecureRandom.uuid) do
          yield
          create_activity(activity_id)
        end
      end
    end

    private

    def validate!
      validate_domain!
      validate_role_change!
    end

    def validate_domain!
      ALLOWED_DOMAINS.include?(user.email.split('@').last) || (raise UnPermittedDomainError)
    end

    def validate_role_change!
      return unless user.persisted?

      user.role_id_changed? && (raise StandardError, t('devise.failure.role_change_on_invite'))
    end

    def create_activity(activity_id)
      Activities::ActivityCreator.new(
        activity_params(activity_id, @activity_action, { role: Role.names[user.role_name] })
      ).call
    end

    def set_action
      @activity_action = user.persisted? ? :user_reinvited : :user_invited
    end
  end
end
