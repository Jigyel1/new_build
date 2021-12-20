# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::DeleteOfferMarketing do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:offer_marketing) { create(:admin_toolkit_offer_marketing) }

  describe '.resolve' do
    context 'with permissions' do
      it 'deletes the offer marketing' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteOfferMarketing)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect do
          AdminToolkit::OfferMarketing.find(offer_marketing.id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deleteOfferMarketing)
        expect(response.offerMarketing).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deleteOfferMarketing( input: { id: "#{offer_marketing.id}" } )
        { status }
      }
    GQL
  end
end
