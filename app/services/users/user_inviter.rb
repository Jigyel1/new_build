# frozen_string_literal: true

module Users
  class UserInviter < BaseService
    ALLOWED_DOMAINS = Rails.application.config.allowed_domains
    attr_accessor :user

    set_callback :call, :before, :check_user_exists?

    class UnPermittedDomainError < StandardError
      def to_s
        I18n.t(
          'domain_validator.unsupported_domain',
          domain: 'domain'.pluralize(DomainValidator::ALLOWED_DOMAINS.size),
          domains: DomainValidator::ALLOWED_DOMAINS.to_sentence
        )
      end
    end

    def call
      run_callbacks :call do
        validate_domain!
        validate_role_change!

        with_tracking(activity_id = SecureRandom.uuid) do
          yield

          Activities::ActivityCreator.new(
            activity_params(activity_id, @activity_action, { role: user.role_name })
          ).call
        end
      end
    end

    private

    def validate_domain!
      ALLOWED_DOMAINS.include?(user.email.split('@').last) || (raise UnPermittedDomainError)
    end

    def validate_role_change!
      return unless user.persisted?

      user.role_id_changed? && (raise StandardError, t('devise.failure.role_change_on_invite'))
    end

    def check_user_exists?
      @activity_action = user.persisted? ? :user_reinvited : :user_invited
    end
  end
end
