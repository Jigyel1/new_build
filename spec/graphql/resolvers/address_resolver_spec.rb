# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AddressResolver do
  let_it_be(:address_a) { build(:address, zip: '8001', city: 'Zurich', street: 'Haldenstrasse') }
  let_it_be(:super_user) { create(:user, :super_user, address: address_a) }

  let_it_be(:address_e) { address_a.dup }
  let_it_be(:project) { create(:project, address: address_e) }

  let_it_be(:address_b) { build(:address, zip: '8002', city: 'Zurich', street: 'Ackerstrasse') }
  let_it_be(:building_a) { create(:building, address: address_b, project: project) }
  let_it_be(:address_c) { build(:address, zip: '8003', city: 'Lucerne', street: 'Bennenegg') }
  let_it_be(:building_b) { create(:building, address: address_c, project: project) }
  let_it_be(:address_d) { build(:address, zip: '8014', city: 'Bern', street: 'Aarbergergasse') }
  let_it_be(:building_c) { create(:building, address: address_d, project: project) }

  describe '.resolve' do
    context 'without filters' do
      it 'returns all addresses for the addressable type' do
        addresses, errors = paginated_collection(
          :addresses,
          query(addressableTypes: ['Projects::Building']),
          current_user: super_user
        )
        expect(errors).to be_nil
        expect(addresses.pluck(:id)).to match_array([address_b.id, address_c.id, address_d.id])
      end
    end

    context 'with zip filter' do
      let!(:zips) { %w[8002 8003] }

      it 'returns addresses matching the given zips' do
        addresses, errors = paginated_collection(
          :addresses,
          query(addressableTypes: ['Projects::Building'], zips: zips),
          current_user: super_user
        )
        expect(errors).to be_nil
        expect(addresses.pluck(:id)).to match_array([address_b.id, address_c.id])
      end
    end

    context 'with city filter' do
      let!(:cities) { %w[Zurich Bern] }

      it 'returns addresses matching the given cities' do
        addresses, errors = paginated_collection(
          :addresses,
          query(addressableTypes: ['Telco::Uam::User'], cities: cities),
          current_user: super_user
        )
        expect(errors).to be_nil
        expect(addresses.pluck(:id)).to match_array([address_a.id])
      end
    end

    context 'with street filter' do
      let!(:streets) { %w[Aarbergergasse Haldenstrasse] }

      it 'returns addresses matching the given streets' do
        addresses, errors = paginated_collection(
          :addresses,
          query(addressableTypes: ['Project', 'Projects::Building'], streets: streets),
          current_user: super_user
        )
        expect(errors).to be_nil
        expect(addresses.pluck(:id)).to match_array([address_d.id, address_e.id])
      end
    end

    context 'with search query' do
      it 'returns addresses matching the query' do
        addresses, errors = paginated_collection(
          :addresses,
          query(addressableTypes: ['Telco::Uam::User', 'Project', 'Projects::Building'], query: 'Strasse '),
          current_user: super_user
        )
        expect(errors).to be_nil
        expect(addresses.pluck(:id)).to match_array([address_a.id, address_b.id, address_e.id])
      end
    end
  end

  def query(args = {})
    connection_query("addresses#{query_string(args)}", 'id city zip street streetNo')
  end
end
