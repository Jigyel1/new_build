# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdatePctValues do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:pct_month) { create(:admin_toolkit_pct_month) }
  let_it_be(:pct_month_b) { create(:admin_toolkit_pct_month, index: 1, min: 13, max: 18) }
  let_it_be(:pct_cost) { create(:admin_toolkit_pct_cost) }
  let_it_be(:pct_cost_b) { create(:admin_toolkit_pct_cost, index: 1, min: 2501, max: 5000) }

  let_it_be(:pct_value) { create(:admin_toolkit_pct_value, pct_month: pct_month, pct_cost: pct_cost) }
  let_it_be(:pct_value_b) { create(:admin_toolkit_pct_value, pct_month: pct_month, pct_cost: pct_cost_b) }
  let_it_be(:pct_value_c) { create(:admin_toolkit_pct_value, pct_month: pct_month_b, pct_cost: pct_cost) }
  let_it_be(:pct_value_d) { create(:admin_toolkit_pct_value, pct_month: pct_month_b, pct_cost: pct_cost_b) }

  describe '.resolve' do
    context 'with valid params' do
      it 'updates PCT data' do
        response, errors = formatted_response(query(status: :on_hold), current_user: super_user, key: :updatePctValues)
        expect(errors).to be_nil

        value = response.pctValues.find { _1[:id] == pct_value_b.id }
        expect(value[:status]).to eq('Prio 2')
        value = response.pctValues.find { _1[:id] == pct_value_c.id }
        expect(value[:status]).to eq('On Hold')
        value = response.pctValues.find { _1[:id] == pct_value_d.id }
        expect(value[:status]).to eq('On Hold')
      end
    end

    context 'with invalid params' do
      it 'responds with error' do
        response, errors = formatted_response(query(status: :invalid), current_user: super_user, key: :updatePctValues)
        expect(response.pctValues).to be_nil
        expect(errors).to eq(["'invalid' is not a valid status"])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updatePctValues(
          input: {
            attributes: [
              {
                id: "#{pct_value_b.id}"
                status: "prio_two"
              },
              {
                id: "#{pct_value_c.id}"
                status: "on_hold"
              },
              {
                id: "#{pct_value_d.id}"
                status: "#{args[:status]}"
              }
            ]
          }
        )
        { pctValues { id status } }
      }
    GQL
  end
end
