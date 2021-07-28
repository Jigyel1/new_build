# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::PenetrationTypesResolver do
  describe '.resolve' do
    it 'returns a list of valid penetration types' do
      response, errors = formatted_response(query)
      expect(errors).to be_nil
      expect(response.penetrationTypes).to match_array(AdminToolkit::Penetration.types.values)
    end
  end

  def query
    <<~GQL
      query { penetrationTypes }
    GQL
  end
end
