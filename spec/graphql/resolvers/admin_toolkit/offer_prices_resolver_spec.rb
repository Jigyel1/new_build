# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::OfferPricesResolver do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:offer_price) { create(:admin_toolkit_offer_price) }
  let_it_be(:offer_price_b) { create(:admin_toolkit_offer_price) }
  let_it_be(:offer_price_c) { create(:admin_toolkit_offer_price) }
  let_it_be(:offer_price_d) { create(:admin_toolkit_offer_price) }

  describe '.resolve' do
    context 'with permissions' do
      it 'returns all offer prices' do
        response, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(response.adminToolkitOfferPrices.count).to eq(4)
      end
    end

    context 'without permissions' do
      it 'forbids the action' do
        response, errors = formatted_response(query, current_user: kam)
        expect(errors).to eq(['Not Authorized'])
        expect(response.adminToolkitOfferPrices).to be_nil
      end
    end
  end

  def query
    <<~GQL
      query{ adminToolkitOfferPrices{ id maxApartments minApartments name value } }
    GQL
  end
end