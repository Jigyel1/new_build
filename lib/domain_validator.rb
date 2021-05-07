# frozen_string_literal: true

class DomainValidator
  ALLOWED_DOMAINS = ENV['ALLOWED_DOMAINS'].delete(' ').split(',').freeze

  class UnPermittedDomainError < StandardError
    def to_s
      I18n.t(
        'domain_validator.unsupported_domain',
        domain: 'domain'.pluralize(DomainValidator::ALLOWED_DOMAINS.size),
        domains: DomainValidator::ALLOWED_DOMAINS.to_sentence
      )
    end
  end

  def initialize(email)
    @email = email
  end

  def run
    permitted? && (return true)

    raise UnPermittedDomainError
  end

  private

  def domain
    @email.split('@').last
  end

  def permitted?
    ALLOWED_DOMAINS.include?(domain)
  end
end
