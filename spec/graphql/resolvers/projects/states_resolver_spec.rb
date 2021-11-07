# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Projects::StatesResolver do
  describe '.resolve' do
    it 'returns all possible states for any project' do
      response, errors = formatted_response('query { projectStates }')
      expect(errors).to be_nil

      expect(OpenStruct.new(response.projectStates).to_h).to eq(
        '0': 'open',
        '1': 'technical_analysis',
        '2': 'technical_analysis_completed',
        '3': 'ready_for_offer',
        '4': 'commercialization',
        '5': 'archived'
      )
    end
  end
end
