# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateOfferAdditionalCost do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:additional_cost) { create(:admin_toolkit_offer_additional_cost) }
  let_it_be(:params) { { id: additional_cost.id, value: -12_331 } }

  describe '.resolve' do
    context 'with valid params' do
      it 'updates the offer_additional_cost record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateOfferAdditionalCost)
        expect(errors).to be_nil
        expect(response.offerAdditionalCost.id).to eq(additional_cost.id)
        expect(response.offerAdditionalCost.value).to eq(-12_331)
      end
    end

    context 'with invalid params' do
      let!(:params_b) { { id: additional_cost.id, value: 12_331 } }

      it 'responds with error' do
        response, errors = formatted_response(query(params_b),
                                              current_user: super_user,
                                              key: :updateOfferAdditionalCost)
        expect(response.offerAdditionalCost).to be_nil
        expect(errors).to eq(['Value must be less than 0'])
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateOfferAdditionalCost)
        expect(response.offerAdditionalCost).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation{
        updateOfferAdditionalCost(input: {
        attributes: {
          id: "#{args[:id]}",
          value: #{args[:value]}
        }
        }){ offerAdditionalCost { additionalCostType id name value } }
      }
    GQL
  end
end
