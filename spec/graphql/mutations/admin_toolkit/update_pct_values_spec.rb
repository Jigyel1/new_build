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
      let!(:params) {
        [
          [pct_value_b.id, 'prio_2'],
          [pct_value_c.id, 'on_hold'],
          [pct_value_d.id, 'on_hold'],
        ]
      }

      it 'updates PCT data' do
        _, errors = formatted_response(query(params), current_user: super_user, key: :updatePctValues)
        expect(errors).to be_nil
        expect(pct_value_b.reload.status).to eq('prio_2')
        expect(pct_value_c.reload.status).to eq('on_hold')
        expect(pct_value_d.reload.status).to eq('on_hold')
      end
    end
  end

  def query(params)
    <<~GQL
      mutation {
        updatePctValues(
          input: {
            attributes: {
              pctValues: #{params}
            }
          }
        )
        { pctValues { id status } }
      }
    GQL
  end
end
