# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Projects::PctCostResolver do
  let_it_be(:project_cost) { create(:admin_toolkit_project_cost) }
  let_it_be(:zip) { '1101' }
  let_it_be(:kam_region) { create(:admin_toolkit_kam_region) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration, zip: zip, kam_region: kam_region, rate: 4.56) }
  let_it_be(:competition) { create(:admin_toolkit_competition, lease_rate: 8.5) }
  let_it_be(:penetration_competition) do
    create(
      :penetration_competition,
      penetration: penetration,
      competition: competition
    )
  end

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :read }) }
  let_it_be(:address) { build(:address, zip: zip) }
  let_it_be(:project) do
    create(
      :project,
      assignee: super_user,
      address: address,
      buildings: build_list(:building, 3, apartments_count: 3)
    )
  end

  describe '.resolve' do
    context 'with valid params' do # wrt a complex project.
      let!(:params) { { project_connection_cost: 999_876, set_project_connection_cost: true, sockets: 20 } }

      before { project.update_column(:category, :complex) }

      it 'returns properly calculated PCT Cost for the project' do
        data, errors = formatted_response(query(params), current_user: super_user)
        expect(errors).to be_nil
        expect(data.projectPctCost).to have_attributes(
          projectCost: 1_016_175.0,
          socketInstallationCost: 16_299.0,
          leaseCost: 20_930.4,
          arpu: 45.66,
          penetrationRate: 4.56,
          paybackPeriod: 602,
          paybackPeriodFormatted: '50 years and 2 months',
          systemGeneratedPaybackPeriod: true,
          projectConnectionCost: 999_876
        )
      end

      it 'throws error if project connection cost is not set' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(data.project).to be_nil
        expect(errors).to eq(["Project connection cost #{t('projects.transition.project_connection_cost_missing')}"])
      end

      it 'returns lease cost if lease_cost_only flag is set' do
        data, errors = formatted_response(query(lease_cost_only: true), current_user: super_user)
        expect(errors).to be_nil
        expect(data.projectPctCost.leaseCost).to eq(20_930.4)
      end
    end

    context 'when penetration is missing for the zip' do
      before { penetration.update_column(:zip, '1103') }

      it 'throws error' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(data.projectPctCost).to be_nil
        expect(errors).to eq(
          ["Penetration #{t('projects.transition.penetration_missing')} and Competition can't be blank"]
        )
      end
    end

    context 'when competition is set' do
      let!(:params) { { competition_id: competition.id } }

      it 'calculates the lease price wrt the lease rate for that competition' do
        data, errors = formatted_response(query(params), current_user: super_user)
        expect(errors).to be_nil
        expect(data.projectPctCost.leaseCost).to eq(20_930.4)
      end
    end

    context 'when competition is not set' do
      let!(:penetration_b) { create(:admin_toolkit_penetration, zip: '1102', kam_region: kam_region) }

      let_it_be(:competition_b) { create(:admin_toolkit_competition, name: 'FTTH SFN', lease_rate: 9.5) }
      let_it_be(:competition_c) { create(:admin_toolkit_competition, name: 'FTTH', lease_rate: 10.5) }

      before do
        create(:penetration_competition, penetration: penetration, competition: competition_b)
        create(:penetration_competition, penetration: penetration_b, competition: competition_c)
      end

      it 'picks the highest lease rate from the admin toolkit for the projects competition' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(data.projectPctCost.leaseCost).to eq(23_392.8)
      end
    end

    context 'for irrelevant projects' do
      before { project.update_column(:category, :irrelevant) }

      it 'sets the project connection cost as 0 if not set' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(data.projectPctCost.projectCost).to eq(0.0)
      end
    end

    context 'for marketing only projects' do
      before { project.update_column(:category, :marketing_only) }

      it 'sets the project connection cost as 0 if not set' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(data.projectPctCost.projectCost).to eq(0.0)
      end
    end
  end

  def project_connection_cost(args = {})
    "projectConnectionCost: #{args[:project_connection_cost]}" if args[:set_project_connection_cost]
  end

  def query(args = {})
    lease_cost_only = args[:lease_cost_only] || false
    sockets = args[:sockets] || 0

    <<~GQL
      query {
        projectPctCost(
          attributes: {
            projectId: "#{project.id}"
            competitionId: "#{args[:competition_id]}"
            leaseCostOnly: #{lease_cost_only}
            sockets: #{sockets}
            #{project_connection_cost(args)}
          }
        )
        {
          id projectCost socketInstallationCost arpu leaseCost penetrationRate
          paybackPeriod paybackPeriodFormatted systemGeneratedPaybackPeriod projectConnectionCost
        }
      }
    GQL
  end
end
