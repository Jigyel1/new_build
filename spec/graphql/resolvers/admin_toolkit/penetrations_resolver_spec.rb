# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::PenetrationsResolver do
  let_it_be(:penetration) { create(:admin_toolkit_penetration, :hfc_footprint, city: 'Chêne-Bougeries') }
  let_it_be(:penetration_b) { create(:admin_toolkit_penetration, :hfc_footprint, :land, city: 'Le Grand-Saconnex') }
  let_it_be(:penetration_c) { create(:admin_toolkit_penetration, :agglo, :f_fast, city: 'Meinier') }
  let_it_be(:penetration_d) { create(:admin_toolkit_penetration, :med_city, :vdsl, city: 'Troinex') }
  let_it_be(:super_user) { create(:user, :super_user) }

  describe '.resolve' do
    context 'for admins' do
      it 'returns all penetrations' do
        penetrations, errors = paginated_collection(:adminToolkitPenetrations, query, current_user: super_user)
        expect(errors).to be_nil
        expect(penetrations.pluck(:id)).to match_array([
          penetration.id, penetration_b.id, penetration_c.id, penetration_d.id
        ])
      end
    end

    context 'for non admins' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam)
        expect(response.adminToolkitPenetrations).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'with search queries' do
      it 'fetches records matching the query' do
        penetrations, errors = paginated_collection(:adminToolkitPenetrations, query(query: 'Bougeries'), current_user: super_user)
        expect(errors).to be_nil
        expect(penetrations.size).to eq(1)
        expect(penetrations.dig(0, :id)).to eq(penetration.id)
      end
    end

    context 'with competitions filter' do
      let(:filters) { { competitions: ['FTTH Swisscom', 'VDSL'] } }

      it 'fetches records matching filter' do
        penetrations, errors = paginated_collection(:adminToolkitPenetrations, query(filters), current_user: super_user)
        expect(errors).to be_nil
        expect(penetrations.pluck(:id)).to contain_exactly(penetration.id, penetration_b.id, penetration_d.id)
      end
    end

    context 'with types filter' do
      let(:filters) { { types: ['Land', 'Agglo'] } }

      it 'fetches records matching filter' do
        penetrations, errors = paginated_collection(:adminToolkitPenetrations, query(filters), current_user: super_user)
        expect(errors).to be_nil
        expect(penetrations.pluck(:id)).to contain_exactly(penetration_b.id, penetration_c.id)
      end
    end

    context 'with footprint availability filter' do
      let(:filters) { { hfc_footprint: true } }

      it 'fetches records matching filter' do
        penetrations, errors = paginated_collection(:adminToolkitPenetrations, query(filters), current_user: super_user)
        expect(errors).to be_nil
        expect(penetrations.pluck(:id)).to contain_exactly(penetration.id, penetration_b.id)
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        adminToolkitPenetrations#{query_string(args)} {
          totalCount
          edges {
            node { id zip city rate competition kamRegion hfcFootprint type }
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
    params = args[:competitions] ? ["competitions: #{args[:competitions]}"] : []
    params << "types: #{args[:types]}" if args[:types].present?
    params << "hfcFootprint: #{args[:hfc_footprint]}" if args[:hfc_footprint]
    params << "query: \"#{args[:query]}\"" if args[:query]

    params.empty? ? nil : "(#{params.join(',')})"
  end
end
