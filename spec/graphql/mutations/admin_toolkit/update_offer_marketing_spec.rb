# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateOfferMarketing do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:offer_marketing) { create(:admin_toolkit_offer_marketing) }
  let_it_be(:params) { { id: offer_marketing.id, value: 1234 } }

  describe '.resolve' do
    context 'with valid params' do
      it 'updates the offer_content record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateOfferMarketing)
        expect(errors).to be_nil
        expect(response.offerMarketing.id).to eq(offer_marketing.id)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateOfferMarketing)
        expect(response.offerMarketing).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation{
        updateOfferMarketing(input: {
        attributes: {
          id: "#{args[:id]}",
          value: #{args[:value]}
        }
        }){
          offerMarketing {
            activityName
            id
            value
          }
        }
      }
    GQL
  end
end
