# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::PenetrationTypesResolver do
  describe '.resolve' do
    it 'returns a list of valid penetration types' do
      expect(execute(query).dig(:data, :penetrationTypes)).to eq(AdminToolkit::Penetration.types)
    end
  end

  def query
    <<~GQL
      query { penetrationTypes }
    GQL
  end
end
