# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateCostThreshold do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:cost_threshold) { create(:admin_toolkit_cost_threshold) }

  let_it_be(:params) { { id: cost_threshold.id, exceeding: 7000 } }

  describe '.resolve' do
    context 'with valid params' do
      it 'updates the cost_threshold record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateCostThreshold)
        expect(errors).to be_nil
        expect(response.costThreshold).to have_attributes(exceeding: 7000)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateCostThreshold)
        expect(response.costThreshold).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateCostThreshold(input: { attributes: {
          id: "#{args[:id]}",
          exceeding: #{args[:exceeding]}
          } }) {
          costThreshold {
            exceeding
            id
            notExceeding
          }
        }
      }
    GQL
  end
end
