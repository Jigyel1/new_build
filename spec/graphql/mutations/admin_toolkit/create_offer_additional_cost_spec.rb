# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::CreateOfferAdditionalCost do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:params) { { name: { en: 'Test' }, additional_cost_type: 'Discount', value: -1234 } }

  describe '.resolve' do
    context 'with valid params' do
      it 'creates the offer_additional_cost record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createOfferAdditionalCost)
        expect(errors).to be_nil
        expect(OpenStruct.new(response.offerAdditionalCost)).to have_attributes(
          additionalCostType: 'discount',
          name: { en: 'Test' },
          value: -1234.0
        )
      end
    end

    context 'with invalid params' do
      let!(:params_b) { { name: { en: 'Test2' }, additional_cost_type: 'Discount', value: 1234 } }

      it 'responds with error' do
        response, errors = formatted_response(query(params_b),
                                              current_user: super_user,
                                              key: :createOfferAdditionalCost)
        expect(response.offerAdditionalCost).to be_nil
        expect(errors).to eq(['Value must be less than 0'])
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :createOfferAdditionalCost)
        expect(response.offerAdditionalCost).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation{
        createOfferAdditionalCost(input: {
        attributes: {
          name: { en: #{args[:name][:en]} },
          value: #{args[:value]},
          additionalCostType: "#{args[:additional_cost_type]}"
        }
        }){
          offerAdditionalCost {
            additionalCostType
            name
            value
          }
        }
      }
    GQL
  end
end
