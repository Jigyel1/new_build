# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::KamInvestorsResolver do
  let_it_be(:kam) { create(:user, :kam, profile: build(:profile, firstname: 'Gannis', lastname: 'Antetokounmpo')) }
  let_it_be(:kam_b) { create(:user, :kam, profile: build(:profile, firstname: 'Jrue', lastname: 'Holiday')) }
  let_it_be(:kam_c) { create(:user, :kam, profile: build(:profile, firstname: 'Chris ', lastname: 'Middleton')) }

  let_it_be(:kam_investor) { create(:kam_investor, investor_id: 'JICA873', kam: kam) }
  let_it_be(:kam_investor_b) { create(:kam_investor, investor_id: 'WBA879', kam: kam_b) }
  let_it_be(:kam_investor_c) { create(:kam_investor, investor_id: 'UNICEF98', kam: kam_c) }

  let_it_be(:super_user) { create(:user, :super_user) }

  describe '.resolve' do
    context 'for admins' do
      it 'returns all kam investors' do
        kam_investors, errors = paginated_collection(:adminToolkitKamInvestors, query, current_user: super_user)
        expect(errors).to be_nil
        expect(kam_investors.pluck(:id)).to match_array(
          [kam_investor.id, kam_investor_b.id, kam_investor_c.id]
        )
      end
    end

    context 'for non admins' do
      it 'forbids action' do
        kam_investors, errors = paginated_collection(:adminToolkitKamInvestors, query, current_user: kam)
        expect(kam_investors).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'with kam ids filter' do
      let(:params) { { kam_ids: [kam_b.id, kam_c.id] } }

      it 'fetches records matching the query' do
        kam_investors, errors = paginated_collection(:adminToolkitKamInvestors, query(params), current_user: super_user)
        expect(errors).to be_nil
        expect(kam_investors.pluck(:id)).to match_array(
          [
            kam_investor_b.id, kam_investor_c.id
          ]
        )
      end
    end

    context 'with search queries' do
      context 'when queried by kam' do
        it 'fetches records matching the query' do
          kam_investors, errors = paginated_collection(
            :adminToolkitKamInvestors, query(query: 'nis ant'), current_user: super_user
          )
          expect(errors).to be_nil
          expect(kam_investors.pluck(:id)).to eq([kam_investor.id])
        end
      end

      context 'when queried by investor id' do
        it 'fetches records matching the query' do
          kam_investors, errors = paginated_collection(
            :adminToolkitKamInvestors, query(query: 'A87'), current_user: super_user
          )
          expect(errors).to be_nil
          expect(kam_investors.pluck(:id)).to match_array([kam_investor.id, kam_investor_b.id])
        end
      end
    end
  end

  def query(args = {})
    connection_query(
      "adminToolkitKamInvestors#{query_string(args)}",
      'id investorId investorDescription kam { id name }'
    )
  end
end
