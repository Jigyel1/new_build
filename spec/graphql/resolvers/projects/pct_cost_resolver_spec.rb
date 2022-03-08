# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Projects::PctCostResolver do
  before_all { create(:admin_toolkit_project_cost) }

  let_it_be(:zip) { '1101' }
  let_it_be(:kam_region) { create(:kam_region) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration, zip: zip, kam_region: kam_region, rate: 0.3507) }
  let_it_be(:competition) { create(:admin_toolkit_competition, lease_rate: 8.5) }
  let_it_be(:penetration_competition) do
    create(:penetration_competition, penetration: penetration, competition: competition)
  end

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :read }) }
  let_it_be(:address) { build(:address, zip: zip) }
  let_it_be(:project) do
    create(
      :project,
      assignee: super_user,
      address: address,
      apartments_count: 1
    )
  end

  describe '.resolve' do
    context 'with valid params' do # wrt a non standard connection.
      before { create(:connection_cost, :non_standard, project: project) }

      let!(:params) { { project_cost: 5000, set_project_cost: true, sockets: 4, cost_type: :non_standard } }

      it 'returns properly calculated PCT Cost for the project' do
        data, errors = formatted_response(query(params), current_user: super_user)
        expect(errors).to be_nil
        expect(data.projectPctCost).to have_attributes(
          projectCost: 6200.0,
          socketInstallationCost: 1200.0,
          leaseCost: 3030.05,
          paybackPeriod: 74.2871994107024,
          paybackPeriodFormatted: '74.29 years',
          systemGeneratedPaybackPeriod: true,
          buildCost: 6252.61,
          roi: 74.29
        )
      end

      it 'throws error if project connection cost is not set' do
        data, errors = formatted_response(query(cost_type: :non_standard), current_user: super_user)
        expect(data.project).to be_nil
        expect(errors).to eq(["Project connection cost #{t('projects.transition.project_connection_cost_missing')}"])
      end
    end

    context 'when penetration is missing for the zip' do
      before do
        create(:connection_cost, project: project)
        penetration.update_column(:zip, '1103')
      end

      it 'throws error' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(data.projectPctCost).to be_nil
        expect(errors).to eq(
          ["Penetration #{t('projects.transition.penetration_missing')} and Competition #{t('errors.messages.blank')}"]
        )
      end
    end

    context 'for standard projects' do
      before { create(:connection_cost, project: project) }

      let!(:params) { { project_cost: 999_876, set_project_cost: true } }

      it 'throws error if project connection cost is sent in the request' do
        data, errors = formatted_response(query(params), current_user: super_user)
        expect(data.projectPctCost).to be_nil
        expect(errors).to eq(["Project connection cost #{t('projects.transition.project_connection_cost_irrelevant')}"])
      end
    end

    context 'with :unknown as the sunrise access option' do
      let!(:unknown_competition) { create(:admin_toolkit_competition, name: :unknown, code: :unknown) }
      let!(:params) { { project_cost: 5000, set_competition: true, competition_id: unknown_competition.id } }

      it 'uses sfn big 4 calculator to calculate the lease cost' do
        data, errors = formatted_response(query(params), current_user: super_user)
        expect(errors).to be_nil
        expect(data.projectPctCost.leaseCost).to eq(3030.05)
      end
    end
  end

  def project_connection_cost(args = {})
    "projectConnectionCost: #{args[:project_cost]}" if args[:set_project_cost]
  end

  def project_competition(args = {})
    "competitionId: \"#{args[:competition_id]}\"" if args[:set_competition]
  end

  def query(args = {})
    sockets = args[:sockets] || 0
    connection_type = args[:connection_type] || :hfc
    cost_type = args[:cost_type] || :standard

    <<~GQL
      query {
        projectPctCost(
          attributes: {
            projectId: "#{project.id}"
            connectionType: "#{connection_type}"
            costType: "#{cost_type}"
            sockets: #{sockets}
            #{project_competition(args)}
            #{project_connection_cost(args)}
          }
        )
        {
          id projectCost socketInstallationCost leaseCost buildCost roi
          paybackPeriod paybackPeriodFormatted systemGeneratedPaybackPeriod
        }
      }
    GQL
  end
end
