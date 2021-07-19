# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdatePenetration do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { id: penetration.id, zip: '8602' } }

      it 'updates the penetration record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updatePenetration)
        expect(errors).to be_nil
        expect(response.penetration).to have_attributes(zip: '8602', city: 'Wangen-Brüttisellen')
      end
    end

    context 'with invalid params' do
      let!(:params) { { id: penetration.id, zip: '' } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updatePenetration)
        expect(response.penetration).to be_nil
        expect(errors).to match_array(["Zip #{t('errors.messages.blank')}"])
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }
      let!(:params) { { id: penetration.id, zip: '8602' } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updatePenetration)
        expect(response.penetration).to be_nil
        expect(errors).to match_array(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updatePenetration(
          input: {
            attributes: {
              id: "#{args[:id]}"
              zip: "#{args[:zip]}"
              city: "Wangen-Brüttisellen"
            }
          }
        )
        { penetration { id zip city rate competition kamRegion hfcFootprint type } }
      }
    GQL
  end
end
