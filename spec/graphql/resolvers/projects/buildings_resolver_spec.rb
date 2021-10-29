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

  let_it_be(:building_a) { create(:building, name: 'Media Markt Winterthur', project: project) }
  let_it_be(:building_b) { create(:building, name: 'Neubau Mehrfamilienhaus mit Coiffeuersalon', project: project) }

  describe '.resolve' do
    context 'without filters' do
      it 'returns all projects' do
        buildings, errors = paginated_collection(:buildings, query, current_user: super_user)
        expect(errors).to be_nil
        expect(buildings.pluck(:id)).to match_array(project.reload.buildings.pluck(:id))
      end
    end

    context 'with search queries' do
      it 'returns buildings matching given query' do
        buildings, errors = paginated_collection(
          :buildings,
          query(query: ' ia Markt Winterthur'),
          current_user: super_user
        )
        expect(errors).to be_nil
        expect(buildings.pluck(:id)).to eq([building_a.id])
      end
    end
  end

  def query(args = {})
    connection_query("buildings#{query_string(args)}", 'id externalId name tasks')
  end

  def query_string(args = {})
    super { { projectId: project.id } }
  end
end
