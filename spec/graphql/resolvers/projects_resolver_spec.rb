# frozen_string_literal: true

require 'rails_helper'
# require_relative '../../support/ips_helper'

RSpec.describe Resolvers::ProjectsResolver do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:team_expert) { create(:user, :team_expert) }

  let_it_be(:address_a) { build(:address, street: 'Sharell Meadows', city: 'New Murray', zip: '16564') }
  let_it_be(:project_a) do
    create(
      :project,
      name: 'Neubau Mehrfamilienhaus mit Coiffeuersalon',
      address: address_a,
      buildings: build_list(:building, 5, apartments_count: 3),
      label_list: 'Assign KAM, Offer Needed'
    )
  end

  let_it_be(:address_b) { build(:address, street: 'Keenan Parkway', city: 'Andrealand', zip: '58710') }
  let_it_be(:project_b) do
    create(
      :project,
      :complex,
      name: "Construction d'une habitation de quatre logements",
      address: address_b,
      assignee: kam,
      buildings: build_list(:building, 15, apartments_count: 6)
    )
  end

  let_it_be(:address_c) { build(:address, street: 'Block Plains', city: 'Anastasiabury', zip: '47736') }
  let_it_be(:project_c) do
    create(
      :project,
      :reactive,
      :b2b_new,
      name: 'Neubau Einfamilienhaus mit Pavillon',
      address: address_c,
      assignee: team_expert,
      buildings: build_list(:building, 25, apartments_count: 8)
    )
  end

  describe '.resolve' do
    context 'without filters' do
      it 'returns all projects' do
        projects, errors = paginated_collection(:projects, query, current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_a.id, project_b.id, project_c.id])
      end
    end

    context 'with categories filter' do
      let(:categories) { ['Complex'] }

      it 'returns projects matching given categories' do
        projects, errors = paginated_collection(:projects, query(categories: categories), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to eq([project_b.id])
      end
    end

    context 'with assignees filter' do
      let(:assignees) { [kam.id, team_expert.id] }

      it 'returns projects matching given assignees' do
        projects, errors = paginated_collection(:projects, query(assignees: assignees), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_b.id, project_c.id])
      end
    end

    context 'with priorities filter' do
      let(:priorities) { ['Reactive'] }

      it 'returns projects matching given priorities' do
        projects, errors = paginated_collection(:projects, query(priorities: priorities), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to eq([project_c.id])
      end
    end

    context 'with construction types filter' do
      let(:construction_types) { ['Reconstruction'] }

      it 'returns projects matching given construction types' do
        projects, errors = paginated_collection(:projects, query(construction_types: construction_types),
                                                current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_a.id, project_b.id])
      end
    end

    context 'with buildings filter' do
      let(:buildings) { [15, 25] }

      it 'returns projects with buildings in the given range' do
        projects, errors = paginated_collection(:projects, query(buildings: buildings), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_b.id, project_c.id])
      end

      context 'when only min value is sent' do
        let(:buildings) { [15] }

        it 'fetches all buildings greater than or equal to the min' do
          projects, errors = paginated_collection(:projects, query(buildings: buildings), current_user: super_user)
          expect(errors).to be_nil
          expect(projects.pluck(:id)).to match_array([project_b.id, project_c.id])
        end
      end
    end

    context 'with apartments filter' do
      let(:apartments) { [16, 90] }

      it 'returns projects with apartments in the given range' do
        projects, errors = paginated_collection(:projects, query(apartments: apartments), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_b.id])
      end
    end

    context 'with search queries' do
      it 'returns projects matching given query' do
        projects, errors = paginated_collection(:projects, query(query: 'Neubau'), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_a.id, project_c.id])
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        projects#{query_string(args)} {
          totalCount
          edges {
            node {#{' '}
              id externalId projectNr name category priority constructionType labels apartmentsCount#{' '}
              moveInStartsOn moveInEndsOn buildingsCount lotNumber address investor assignee kamRegion
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

  def query_string(args = {}) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
    params = args[:categories] ? ["categories: #{args[:categories]}"] : []
    params << "assignees: #{args[:assignees]}" if args[:assignees].present?
    params << "priorities: #{args[:priorities]}" if args[:priorities].present?
    params << "constructionTypes: #{args[:construction_types]}" if args[:construction_types].present?
    params << "buildingsCount: #{args[:buildings]}" if args[:buildings].present?
    params << "apartmentsCount: #{args[:apartments]}" if args[:apartments].present?
    params << "query: \"#{args[:query]}\"" if args[:query]
    # params << "first: #{args[:first]}" if args[:first]
    # params << "skip: #{args[:skip]}" if args[:skip]

    params.empty? ? nil : "(#{params.join(',')})"
  end
end
