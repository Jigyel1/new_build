# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::DepartmentsResolver do
  describe '.resolve' do
    it 'returns departments that the server will accept' do
      response, errors = formatted_response(query)
      expect(errors).to be_nil
      expect(response.departments).to match_array(Rails.application.config.user_departments)
    end
  end

  def query
    <<~GQL
      query { departments }
    GQL
  end
end
