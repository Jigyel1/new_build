# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::DeleteOfferContent do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:offer_content) { create(:admin_toolkit_offer_content) }

  describe '.resolve' do
    context 'with permissions' do
      it 'deletes the kam investor' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteOfferContent)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect do
          AdminToolkit::OfferContent.find(offer_content.id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deleteOfferContent)
        expect(response.offerContent).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deleteOfferContent( input: { id: "#{offer_content.id}" } )
        { status }
      }
    GQL
  end
end
