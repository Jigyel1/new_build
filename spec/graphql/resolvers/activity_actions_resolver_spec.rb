# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::ActivityActionsResolver do
  describe '.resolve' do
    it 'returns actions by resource' do
      response, errors = formatted_response(query)
      expect(errors).to be_nil
      expect(response.activityActions.to_json).to eq(Activity::VALID_ACTIONS.to_json)
    end
  end

  def query
    <<~GQL
      query { activityActions }
    GQL
  end
end
