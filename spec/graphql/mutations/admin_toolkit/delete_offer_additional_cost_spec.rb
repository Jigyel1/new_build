# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::DeleteOfferAdditionalCost do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:additional_cost) { create(:admin_toolkit_offer_additional_cost) }

  describe '.resolve' do
    context 'with permissions' do
      it 'deletes the kam investor' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteOfferAdditionalCost)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect do
          AdminToolkit::OfferAdditionalCost.find(additional_cost.id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deleteOfferAdditionalCost)
        expect(response.offerAdditionalCost).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deleteOfferAdditionalCost( input: { id: "#{additional_cost.id}" } )
        { status }
      }
    GQL
  end
end
