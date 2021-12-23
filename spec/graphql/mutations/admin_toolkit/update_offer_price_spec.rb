# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateOfferPrice do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:offer_price) { create(:admin_toolkit_offer_price) }
  let_it_be(:offer_price_b) do
    create(:admin_toolkit_offer_price,
           index: 1, min_apartments: 6,
           max_apartments: 12, value: 2500)
  end
  let_it_be(:params) { { id: offer_price.id, max_apartments: 7 } }

  describe '.resolve' do
    context 'with valid params' do
      it 'updates the offer_price record and increments offer_price_b min_apartments' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateOfferPrice)
        expect(errors).to be_nil
        expect(response.offerPrice.id).to eq(offer_price.id)

        target_offer_price = AdminToolkit::OfferPrice.find(offer_price_b.id)
        expect(target_offer_price.min_apartments).to eq(8)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateOfferPrice)
        expect(response.offerPrice).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation{
        updateOfferPrice(input: {
        attributes:{
          id: "#{args[:id]}",
          maxApartments: #{args[:max_apartments]}
        }
        }){
          offerPrice {
            id
            maxApartments
            minApartments
            name
            value
          }
        }
      }
    GQL
  end
end
