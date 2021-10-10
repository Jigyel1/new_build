# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::KamRegionsResolver do
  let_it_be(:kam) { create(:user, :kam, profile: build(:profile, firstname: 'Gannis', lastname: 'Antetokounmpo')) }
  let_it_be(:kam_b) { create(:user, :kam, profile: build(:profile, firstname: 'Jrue', lastname: 'Holiday')) }
  let_it_be(:kam_c) { create(:user, :kam, profile: build(:profile, firstname: 'Chris ', lastname: 'Middleton')) }

  let_it_be(:kam_region) { create(:kam_region, name: 'Romandie', kam: kam) }
  let_it_be(:kam_region_b) { create(:kam_region, name: 'Ticino', kam: kam_b) }
  let_it_be(:kam_region_c) { create(:kam_region, name: 'Ost ZH', kam: kam_c) }

  let_it_be(:super_user) { create(:user, :super_user) }

  describe '.resolve' do
    context 'for admins' do
      it 'returns all kam investors' do
        kam_regions, errors = paginated_collection(:adminToolkitKamRegions, query, current_user: super_user)
        expect(errors).to be_nil
        expect(kam_regions.pluck(:id)).to match_array(
          [kam_region.id, kam_region_b.id, kam_region_c.id]
        )
      end
    end

    context 'for non admins' do
      it 'forbids action' do
        kam_regions, errors = paginated_collection(:adminToolkitKamRegions, query, current_user: kam)
        expect(kam_regions).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'with kam ids filter' do
      let(:params) { { kam_ids: [kam_b.id, kam_c.id] } }

      it 'fetches records matching the query' do
        kam_regions, errors = paginated_collection(:adminToolkitKamRegions, query(params), current_user: super_user)
        expect(errors).to be_nil
        expect(kam_regions.pluck(:id)).to match_array(
          [
            kam_region_b.id, kam_region_c.id
          ]
        )
      end
    end

    context 'with search queries' do
      context 'when queried by kam' do
        it 'fetches records matching the query' do
          kam_regions, errors = paginated_collection(
            :adminToolkitKamRegions, query(query: 'nis ant'), current_user: super_user
          )
          expect(errors).to be_nil
          expect(kam_regions.pluck(:id)).to eq([kam_region.id])
        end
      end

      context 'when queried by name' do
        it 'fetches records matching the query' do
          kam_regions, errors = paginated_collection(
            :adminToolkitKamRegions, query(query: 'cino  '), current_user: super_user
          )
          expect(errors).to be_nil
          expect(kam_regions.pluck(:id)).to eq([kam_region_b.id])
        end
      end
    end
  end

  def query(args = {})
    connection_query("adminToolkitKamRegions#{query_string(args)}", 'id name kam { id name }')
  end

  def query_string(args = {})
    params = args[:kam_ids] ? ["kamIds: #{args[:kam_ids]}"] : []
    params << "query: \"#{args[:query]}\"" if args[:query]
    params.empty? ? nil : "(#{params.join(',')})"
  end
end
