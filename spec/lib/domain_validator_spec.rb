# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DomainValidator do
  let_it_be(:allowed_domains) { ENV['ALLOWED_DOMAINS'].split(',') }

  context 'with allowed domain' do
    subject(:validator) { described_class.new("ym@#{allowed_domains.first}") }

    it 'does not raise exception' do
      expect { validator.run }.not_to raise_error
    end
  end

  context 'with unsupported domain' do
    subject(:validator) { described_class.new('ym@selco.ch') }

    it 'raises UnSupportedDomainError' do
      expect { validator.run }.to raise_error(DomainValidator::UnPermittedDomainError)
    end
  end
end
