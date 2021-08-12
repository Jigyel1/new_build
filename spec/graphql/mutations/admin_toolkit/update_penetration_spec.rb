# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdatePenetration do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam_region) { create(:admin_toolkit_kam_region) }

  let_it_be(:competition_a) { create(:admin_toolkit_competition) }
  let_it_be(:competition_b) { create(:admin_toolkit_competition, :g_fast) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration, kam_region: kam_region) }

  let_it_be(:penetration_competition_a) do
    create(:penetration_competition, penetration: penetration, competition: competition_a)
  end

  let_it_be(:penetration_competition_b) do
    create(:penetration_competition, penetration: penetration, competition: competition_b)
  end

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { id: penetration.id, zip: '8602' } }

      it 'updates the penetration record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updatePenetration)
        expect(errors).to be_nil
        expect(response.penetration).to have_attributes(zip: '8602', city: 'Wangen-Brüttisellen')

        expect(response.penetration.penetrationCompetitions.size).to eq(1)
        competition = response.penetration.penetrationCompetitions.dig(0, :competition)
        expect(OpenStruct.new(competition)).to have_attributes(
                                                         id: competition_b.id,
                                                         name: competition_b.name
                                                       )
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
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def penetration_competitions
    <<~PENETRATION_COMPETITIONS
      penetrationCompetitions: [
        {
          id: "#{penetration_competition_a.id}",
          competitionId: "#{competition_b.id}"
        },
        {
           id: "#{penetration_competition_b.id}",
           _destroy: 1
        }
      ]
    PENETRATION_COMPETITIONS
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
              #{penetration_competitions}
            }
          }
        )
        { 
          penetration { 
            id zip city rate hfcFootprint type kamRegion { id kam { name } } 
            penetrationCompetitions { id competition { id name } }
          } 
        }
      }
    GQL
  end
end
