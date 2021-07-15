# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::PctsResolver do
  let_it_be(:pct_month) { create(:admin_toolkit_pct_month) }
  let_it_be(:pct_month_b) { create(:admin_toolkit_pct_month, index: 1, min: 13, max: 18) }
  let_it_be(:pct_cost) { create(:admin_toolkit_pct_cost) }
  let_it_be(:pct_cost_b) { create(:admin_toolkit_pct_cost, index: 1, min: 2501, max: 5000) }

  let_it_be(:pct_value) { create(:admin_toolkit_pct_value, pct_month: pct_month, pct_cost: pct_cost) }
  let_it_be(:pct_value_b) { create(:admin_toolkit_pct_value, pct_month: pct_month, pct_cost: pct_cost_b) }
  let_it_be(:pct_value_c) { create(:admin_toolkit_pct_value, pct_month: pct_month_b, pct_cost: pct_cost) }
  let_it_be(:pct_value_d) { create(:admin_toolkit_pct_value, pct_month: pct_month_b, pct_cost: pct_cost_b) }

  describe '.resolve' do
    context 'for admins' do
      let_it_be(:super_user) { create(:user, :super_user) }

      it 'returns all footprint values' do
        response, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(response.pcts.pluck(:id)).to match_array([
          pct_value.id, pct_value_b.id, pct_value_c.id, pct_value_d.id
        ])
      end
    end

    context 'for non admins' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam)
        expect(response.footprints).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      query { 
        pcts {
          id status
          pctCost { index min max }
          pctMonth { index min max}
        }       
      }
    GQL
  end
end
