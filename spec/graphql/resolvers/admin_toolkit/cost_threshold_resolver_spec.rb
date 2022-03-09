# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::CostThresholdResolver do
  let_it_be(:cost_threshold) { create(:admin_toolkit_cost_threshold) }

  describe '.resolve' do
    context 'for admins' do
      let(:super_user) { create(:user, :super_user) }

      it 'returns cost threshold value' do
        response, errors = formatted_response(query, current_user: super_user)
        expect(response.adminToolkitCostThreshold.count).to eq(1)
        expect(errors).to be_nil
      end
    end

    context 'for non admins' do
      let(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam)
        expect(response.costThreshold).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      query { adminToolkitCostThreshold { exceeding id } }
    GQL
  end
end
