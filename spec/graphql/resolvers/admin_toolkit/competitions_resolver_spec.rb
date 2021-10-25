# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::CompetitionsResolver do
  let_it_be(:competition) { create(:admin_toolkit_competition, name: 'FTTH SC', factor: 1.3, lease_rate: 87) }
  let_it_be(:competition_b) { create(:admin_toolkit_competition, name: 'FTTH EVU', factor: 1.6, lease_rate: 56) }
  let_it_be(:competition_c) { create(:admin_toolkit_competition, name: 'G.fast', factor: 0.3, lease_rate: 23) }
  let_it_be(:competition_d) { create(:admin_toolkit_competition, name: 'VDSL', factor: 0.34, lease_rate: 9) }
  let_it_be(:super_user) { create(:user, :super_user) }

  describe '.resolve' do
    context 'for admins' do
      it 'returns all competitions' do
        competitions, errors = paginated_collection(:adminToolkitCompetitions, query, current_user: super_user)
        expect(errors).to be_nil
        expect(competitions.pluck(:id)).to match_array(
          [competition.id, competition_b.id, competition_c.id, competition_d.id]
        )
      end
    end

    context 'for non admins' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam)
        expect(response.adminToolkitCompetitions).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'with search queries' do
      context 'when queried for factor' do
        it 'fetches records matching the query' do
          competitions, errors = paginated_collection(
            :adminToolkitCompetitions, query(query: '3'), current_user: super_user
          )
          expect(errors).to be_nil
          expect(competitions.pluck(:id)).to match_array([competition.id, competition_c.id, competition_d.id])
        end
      end

      context 'when queried for name' do
        it 'fetches records matching the query' do
          competitions, errors = paginated_collection(
            :adminToolkitCompetitions, query(query: 'ftth'), current_user: super_user
          )
          expect(errors).to be_nil
          expect(competitions.pluck(:id)).to match_array([competition.id, competition_b.id])
        end
      end
    end
  end

  def query(args = {})
    connection_query("adminToolkitCompetitions#{query_string(args)}", 'id factor leaseRate name description')
  end
end
