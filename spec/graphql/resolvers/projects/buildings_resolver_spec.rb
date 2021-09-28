# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Projects::BuildingsResolver do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :read }) }
  let_it_be(:address) { build(:address, street: 'Sharell Meadows', city: 'New Murray', zip: '16564') }

  let_it_be(:project) do
    create(
      :project,
      name: 'Neubau Mehrfamilienhaus mit Coiffeuersalon',
      address: address,
      buildings: build_list(:building, 5, apartments_count: 3),
      label_list: 'Assign KAM, Offer Needed'
    )
  end

  let_it_be(:building) { create(:building, name: 'Media Markt Winterthur', project: project) }

  describe '.resolve' do
    context 'without filters' do
      it 'returns all projects' do
        buildings, errors = paginated_collection(:buildings, query, current_user: super_user)
        expect(errors).to be_nil
        expect(buildings.pluck(:id)).to match_array(project.reload.buildings.pluck(:id))
      end
    end

    context 'with search queries' do
      it 'returns projects matching given query' do
        buildings, errors = paginated_collection(:buildings, query(query: ' ia Markt Winterthur'),
                                                 current_user: super_user)
        expect(errors).to be_nil
        expect(buildings.pluck(:id)).to eq([building.id])
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        buildings#{query_string(args)} {
          totalCount
          edges {
            node {
              id externalId name tasks
            }
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
    params = ["projectId: \"#{project.id}\""]
    params << "query: \"#{args[:query]}\"" if args[:query]

    params.empty? ? nil : "(#{params.join(',')})"
  end
end
