# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::KamMappingsResolver do
  let_it_be(:kam) { create(:user, :kam, profile: build(:profile, firstname: 'Gannis', lastname: 'Antetokounmpo')) }
  let_it_be(:kam_b) { create(:user, :kam, profile: build(:profile, firstname: 'Jrue', lastname: 'Holiday')) }
  let_it_be(:kam_c) { create(:user, :kam, profile: build(:profile, firstname: 'Chris ', lastname: 'Middleton')) }

  let_it_be(:kam_mapping) { create(:admin_toolkit_kam_mapping, investor_id: 'JICA873', kam: kam) }
  let_it_be(:kam_mapping_b) { create(:admin_toolkit_kam_mapping, investor_id: 'WBA879', kam: kam_b) }
  let_it_be(:kam_mapping_c) { create(:admin_toolkit_kam_mapping, investor_id: 'UNICEF98', kam: kam_c) }

  let_it_be(:super_user) { create(:user, :super_user) }

  describe '.resolve' do
    context 'for admins' do
      it 'returns all kam mappings' do
        kam_mappings, errors = paginated_collection(:adminToolkitKamMappings, query, current_user: super_user)
        expect(errors).to be_nil
        expect(kam_mappings.pluck(:id)).to match_array(
          [
            kam_mapping.id, kam_mapping_b.id, kam_mapping_c.id
          ]
        )
      end
    end

    context 'for non admins' do
      it 'forbids action' do
        kam_mappings, errors = paginated_collection(:adminToolkitKamMappings, query, current_user: kam)
        expect(kam_mappings).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'with kam ids filter' do
      let(:params) { { kam_ids: [kam_b.id, kam_c.id] } }

      it 'fetches records matching the query' do
        kam_mappings, errors = paginated_collection(:adminToolkitKamMappings, query(params), current_user: super_user)
        expect(errors).to be_nil
        expect(kam_mappings.pluck(:id)).to match_array(
          [
            kam_mapping_b.id, kam_mapping_c.id
          ]
        )
      end
    end

    context 'with search queries' do
      context 'when queried by kam' do
        it 'fetches records matching the query' do
          kam_mappings, errors = paginated_collection(:adminToolkitKamMappings, query(query: 'nis ant'),
                                                      current_user: super_user)
          expect(errors).to be_nil
          expect(kam_mappings.pluck(:id)).to eq([kam_mapping.id])
        end
      end

      context 'when queried by investor id' do
        it 'fetches records matching the query' do
          kam_mappings, errors = paginated_collection(:adminToolkitKamMappings, query(query: 'A87'),
                                                      current_user: super_user)
          expect(errors).to be_nil
          expect(kam_mappings.pluck(:id)).to match_array([kam_mapping.id, kam_mapping_b.id])
        end
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        adminToolkitKamMappings#{query_string(args)} {
          totalCount
          edges {
            node { id investorId investorDescription kam { id name } }
          }
          pageInfo {
            endCursor
            startCursor
            hasNextPage
            hasPreviousPage
          }
        }
      }
    GQL
  end

  def query_string(args = {})
    params = args[:kam_ids] ? ["kamIds: #{args[:kam_ids]}"] : []
    params << "query: \"#{args[:query]}\"" if args[:query]
    params.empty? ? nil : "(#{params.join(',')})"
  end
end
