# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdatePctCost do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:pct_cost) { create(:admin_toolkit_pct_cost) }
  let_it_be(:pct_cost_b) { create(:admin_toolkit_pct_cost, index: 1, min: 2501, max: 5000) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { id: pct_cost.id, max: 2600 } }

      it 'updates PCT data' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updatePctCost)
        expect(errors).to be_nil
        expect(response.pctCost).to have_attributes(max: 2600)
      end

      it 'propagates update to the next PCT table' do
        _, errors = formatted_response(query(params), current_user: super_user, key: :updatePctCost)
        expect(errors).to be_nil
        expect(pct_cost_b.reload).to have_attributes(min: 2601)
      end
    end

    context 'with invalid params' do
      let!(:params) { { id: pct_cost.id, max: -1 } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updatePctCost)
        expect(response.pctCost).to be_nil
        expect(errors).to match_array(['Max must be greater than or equal to 0'])
      end
    end

    context 'when max exceeds or is equal to the PCT max of the adjacent table' do
      let!(:params) { { id: pct_cost.id, max: 5000 } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updatePctCost)
        expect(response.pctCost).to be_nil
        expect(errors).to match_array([
                                        t('admin_toolkit.pct_cost.invalid_min',
                                          header: pct_cost_b.header,
                                          new_max: 5001,
                                          old_max: 5000)
                                      ])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updatePctCost(
          input: {
            attributes: {
              id: "#{args[:id]}"
              max: #{args[:max]}#{' '}
            }
          }
        )
        { pctCost { id max min header } }
      }
    GQL
  end
end
