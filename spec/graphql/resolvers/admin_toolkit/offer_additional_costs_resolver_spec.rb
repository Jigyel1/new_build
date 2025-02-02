# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::OfferAdditionalCostsResolver do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:additional_cost_a) { create(:admin_toolkit_offer_additional_cost) }
  let_it_be(:additional_cost_b) { create(:admin_toolkit_offer_additional_cost) }
  let_it_be(:additional_cost_c) { create(:admin_toolkit_offer_additional_cost) }
  let_it_be(:additional_cost_d) { create(:admin_toolkit_offer_additional_cost) }

  describe '.resolve' do
    context 'with permissions' do
      it 'returns all offer additional costs' do
        response, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(response.adminToolkitOfferAdditionalCosts.count).to eq(4)
      end
    end

    context 'without permissions' do
      it 'forbids the action' do
        response, errors = formatted_response(query, current_user: kam)
        expect(errors).to eq(['Not Authorized'])
        expect(response.adminToolkitOfferAdditionalCosts).to be_nil
      end
    end
  end

  def query
    <<~GQL
      query{ adminToolkitOfferAdditionalCosts{ additionalCostType id name value } }
    GQL
  end
end
