# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::CreatePenetration do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:competition) { create(:admin_toolkit_competition) }
  let_it_be(:kam_region) { create(:admin_toolkit_kam_region) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { zip: '8602' } }

      it 'creates the penetration record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createPenetration)
        expect(errors).to be_nil
        expect(response.penetration).to have_attributes(
          zip: '8602',
          city: 'Wangen-Brüttisellen',
          rate: '19.22',
          type: 'land',
          hfcFootprint: false
        )

        expect(response.penetration.kamRegion.name).to eq(kam_region.name)
        expect(response.penetration.competition.name).to eq(competition.name)
      end
    end

    context 'with invalid params' do
      let!(:params) { { zip: '' } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createPenetration)
        expect(response.penetration).to be_nil
        expect(errors).to match_array(["Zip #{t('errors.messages.blank')}"])
      end
    end

    context 'without permissions' do
      let!(:kam) { create(:user, :kam) }
      let!(:params) { { zip: '8602' } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :createPenetration)
        expect(response.penetration).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        createPenetration(
          input: {
            attributes: {
              zip: "#{args[:zip]}"
              city: "Wangen-Brüttisellen"
              rate: "19.22"
              kamRegionId: "#{kam_region.id}"
              type: "Land"
              competitionId: "#{competition.id}"
              hfcFootprint: false
            }
          }
        )
        { penetration { id zip city rate competition { name } hfcFootprint type kamRegion { name kam { name }} } }
      }
    GQL
  end
end
