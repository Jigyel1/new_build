# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::OfferMarketingsResolver do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:offer_marketing) { create(:admin_toolkit_offer_marketing) }
  let_it_be(:offer_marketing_b) { create(:admin_toolkit_offer_marketing) }
  let_it_be(:offer_marketing_c) { create(:admin_toolkit_offer_marketing) }
  let_it_be(:offer_marketing_d) { create(:admin_toolkit_offer_marketing) }

  describe '.resolve' do
    context 'with permissions' do
      it 'returns all offer marketings' do
        response, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(response.adminToolkitOfferMarketings.count).to eq(4)
      end
    end

    context 'without permissions' do
      it 'forbids the action' do
        response, errors = formatted_response(query, current_user: kam)
        expect(errors).to eq(['Not Authorized'])
        expect(response.adminToolkitOfferMarketings).to be_nil
      end
    end
  end

  def query
    <<~GQL
      query{ adminToolkitOfferMarketings{ activityName id value } }
    GQL
  end
end
