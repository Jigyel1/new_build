# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateOfferContent do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:offer_content) { create(:admin_toolkit_offer_content) }
  let_it_be(:params) { { id: offer_content.id, title: { en: 'Update Tester' } } }

  describe '.resolve' do
    context 'with valid params' do
      it 'updates the offer_content record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateOfferContent)
        expect(errors).to be_nil
        expect(response.offerContent.id).to eq(offer_content.id)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateOfferContent)
        expect(response.offerContent).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation{
        updateOfferContent(input: {
        attributes: {
          id: "#{args[:id]}",
          title: { en: "#{args[:title][:en]}" }
        }
        }){
          offerContent {
            content
            id
            title
          }
        }
      }
    GQL
  end
end
