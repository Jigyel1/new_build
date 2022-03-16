# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/ips_helper'

RSpec.describe Resolvers::ProjectsResolver do
  include IpsHelper

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :read }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:team_expert) { create(:user, :team_expert) }

  let_it_be(:kam_region_a) { create(:kam_region, name: 'Romandie') }
  let_it_be(:kam_region_b) { create(:kam_region, name: 'West Bern-Seeland') }
  let_it_be(:penetration_a) { create(:admin_toolkit_penetration, zip: '16564', kam_region: kam_region_a) }
  let_it_be(:penetration_b) { create(:admin_toolkit_penetration, zip: '47736', kam_region: kam_region_b) }

  let_it_be(:address_a) { build(:address, street: 'Sharell Meadows', city: 'New Murray', zip: '16564') }
  let_it_be(:project_a) do
    create(
      :project,
      :customer_request,
      internal_id: '312590',
      name: 'Neubau Mehrfamilienhaus mit Coiffeuersalon',
      address: address_a,
      buildings: build_list(:building, 5, apartments_count: 3),
      label_list: 'Assign KAM, Offer Needed',
      lot_number: 'Parz. 277, 1617'
    )
  end

  let_it_be(:address_b) { build(:address, street: 'Keenan Parkway', city: 'Andrealand', zip: '58710') }
  let_it_be(:project_b) do
    create(
      :project,
      :complex,
      :technical_analysis,
      customer_request: false,
      internal_id: '312591',
      name: "Construction d'une habitation de quatre logements",
      address: address_b,
      assignee: kam,
      buildings: build_list(:building, 15, apartments_count: 6),
      lot_number: 'Parz. 120'
    )
  end

  let_it_be(:address_c) { build(:address, street: 'Block Plains', city: 'Anastasiabury', zip: '47736') }
  let_it_be(:project_c) do
    create(
      :project,
      :reactive,
      :new_construction,
      :technical_analysis_completed,
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

      it 'returns count of each project status' do
        response = execute(query, current_user: super_user)
        expect(OpenStruct.new(response.dig(:data, :projects, :countByStatuses))).to have_attributes(
          open: 1,
          technical_analysis: 1,
          technical_analysis_completed: 1
        )
      end
    end

    context 'with statuses filter' do
      let(:statuses) { %w[technical_analysis open] }

      it 'returns projects matching given categories' do
        projects, errors = paginated_collection(:projects, query(statuses: statuses), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_a.id, project_b.id])
      end
    end

    context 'with categories filter' do
      let(:categories) { ['complex'] }

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

    context 'with internal ids filter' do
      let(:internal_ids) { %w[312590 312591] }

      it 'returns projects matching given internal ids' do
        projects, errors = paginated_collection(:projects, query(internal_ids: internal_ids), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_a.id, project_b.id])
      end
    end

    context 'with buildings filter' do
      let(:buildings) { [15, 25] }

      it 'returns projects with buildings in the given range' do
        projects, errors = paginated_collection(:projects, query(buildings_count: buildings), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_b.id, project_c.id])
      end

      context 'when only min value is sent' do
        let(:buildings) { [15] }

        it 'fetches all buildings greater than or equal to the min' do
          projects, errors = paginated_collection(:projects, query(buildings_count: buildings),
                                                  current_user: super_user)
          expect(errors).to be_nil
          expect(projects.pluck(:id)).to match_array([project_b.id, project_c.id])
        end
      end
    end

    context 'with apartments filter' do
      let(:apartments) { [16, 90] }

      it 'returns projects with apartments in the given range' do
        projects, errors = paginated_collection(:projects, query(apartments_count: apartments),
                                                current_user: super_user)
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

    describe 'performance benchmarks' do
      it 'executes within 30 ms' do
        expect { paginated_collection(:projects, query, current_user: super_user) }.to perform_under(30).ms
      end

      it 'executes n iterations in x seconds', ips: true do
        expect { paginated_collection(:users, query, current_user: super_user) }.to(
          perform_at_least(perform_atleast).within(perform_within).warmup(warmup_for).ips
        )
      end
    end

    context 'without read permission' do
      it 'forbids action' do
        projects, errors = paginated_collection(:projects, query, current_user: kam)
        expect(projects).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'when assignee is not set' do
      it 'returns assignee type instead of assignee' do
        projects, errors = paginated_collection(:projects, query, current_user: super_user)
        expect(errors).to be_nil

        project = OpenStruct.new(projects.find { _1[:id] == project_a.id })
        expect(project.assignee).to eq('NBO Project')
      end
    end

    context 'with customer_request filter' do
      let(:customer_requests) { [true] }

      it 'returns projects matching customer request filter' do
        projects, errors = paginated_collection(
          :projects,
          query(customerRequests: customer_requests),
          current_user: super_user
        )
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_a.id, project_c.id])
      end
    end

    context 'with kam_regions filter' do
      let(:kam_regions) { [kam_region_a.name, kam_region_b.name] }

      it 'returns projects matching kam_regions filter' do
        projects, errors = paginated_collection(:projects, query(kamRegions: kam_regions), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_a.id, project_c.id])
      end
    end

    context 'with lot number filter' do
      let!(:lot_numbers) { '120' }

      it 'returns projects matching the given lot numbers' do
        projects, errors = paginated_collection(:projects, query(lotNumbers: lot_numbers), current_user: super_user)
        expect(errors).to be_nil
        expect(projects.pluck(:id)).to match_array([project_b.id])
      end
    end
  end

  def query(args = {})
    response = <<~RESPONSE
      id externalId projectNr name status category priority constructionType labels apartmentsCount
      moveInStartsOn moveInEndsOn buildingsCount lotNumber address investor assignee kamRegion
    RESPONSE

    connection_query(
      "projects#{query_string(args)}",
      response,
      meta: 'countByStatuses'
    )
  end
end
