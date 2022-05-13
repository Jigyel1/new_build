# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::TransitionToTechnicalAnalysisCompleted do
  let_it_be(:zip) { '1101' }
  let_it_be(:project_cost) { create(:admin_toolkit_project_cost, standard: 99_987) }
  let_it_be(:kam_region) { create(:kam_region) }
  let_it_be(:label_group_a) { create(:admin_toolkit_label_group, :technical_analysis_completed) }
  let_it_be(:label_group_b) { create(:admin_toolkit_label_group, :ready_for_offer) }

  let_it_be(:competition) { create(:admin_toolkit_competition) }
  let_it_be(:cost_threshold) { create(:admin_toolkit_cost_threshold) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration, zip: zip, kam_region: kam_region, rate: 0.56) }
  let_it_be(:penetration_competition) do
    create(:penetration_competition, penetration: penetration, competition: competition)
  end

  let_it_be(:pct_value) do
    create(
      :admin_toolkit_pct_value,
      :prio_two,
      pct_month: create(:admin_toolkit_pct_month, min: 1, max: 55),
      pct_cost: create(:admin_toolkit_pct_cost, min: 1187, max: 200_000)
    )
  end

  let_it_be(:super_user) do
    create(
      :user,
      :super_user,
      with_permissions: {
        project: %i[
          complex
          ready_for_offer
        ]
      }
    )
  end

  let_it_be(:address) { build(:address, zip: zip) }
  let_it_be(:project) { create(:project, :technical_analysis, address: address, incharge: super_user) }
  let_it_be(:building) { create(:building, apartments_count: 30, project: project) }

  let_it_be(:connection_cost_str) { '{ connectionType: "hfc", costType: "standard"}' }

  let_it_be(:params) do
    {
      connection_costs: '
            {
              connectionType: "hfc",
              costType: "standard"
            },
            {
              connectionType: "ftth",
              costType: "standard",
            }
          '
    }
  end

  describe '.resolve' do
    context 'with permissions' do
      it 'updates project status' do
        response, errors = formatted_response(
          query(params),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(errors).to be_nil
        expect(response.project).to have_attributes(cableInstallations: %w[FTTH Coax])
        expect(response.project.status).to eq('technical_analysis_completed')
        expect(response.project.verdicts).to have_attributes(
          technical_analysis_completed: 'This projects looks feasible with the current resources.'
        )

        expect(project.default_label_group.reload.label_list).to include('Prio 2')
        expect(project.connection_costs.pluck(:connection_type)).to match_array(%w[hfc ftth])
      end
    end

    context 'without permissions' do
      let_it_be(:admin) { create(:user, :administrator) }
      before { project.update_columns(incharge_id: admin.id, category: :complex) }

      it 'forbids action' do
        response, errors = formatted_response(
          query(set_pct_cost: true, connection_costs: connection_cost_str),
          current_user: admin,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
        expect(project.reload.status).to eq('technical_analysis')
      end
    end

    context 'when user is not the project incharge' do
      let_it_be(:admin) { create(:user, :administrator, with_permissions: { project: :complex }) }

      it 'forbids action' do
        response, errors = formatted_response(
          query(connection_costs: connection_cost_str),
          current_user: admin,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
        expect(project.reload.status).to eq('technical_analysis')
      end
    end

    context 'when both connection types are too expensive' do
      before { project.update_column(:category, :complex) }

      it 'marks the project irrelevant and archives it' do
        response, errors = formatted_response(
          query(
            set_pct_cost: true,
            connection_costs: '
              {
                connectionType: "hfc",
                costType: "too_expensive"
              },
              {
                connectionType: "ftth",
                costType: "too_expensive"
              }
            '
          ),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(response.project).to be_nil
        expect(errors).to eq([t('projects.transition.archiving_expensive_project')])
        expect(project.reload).to have_attributes(status: 'archived')
      end
    end

    context 'for HFC only projects' do
      it 'when cost type for HFC only project is too_expensive, it archives the project' do
        response, errors = formatted_response(
          query(connection_costs: '{ connectionType: "hfc", costType: "too_expensive" }'),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(response.project).to be_nil
        expect(errors).to eq([t('projects.transition.archiving_expensive_project')])
        expect(project.reload.status).to eq('archived')
      end
    end

    context 'when in house installation is selected' do
      it 'throws error if in house details are not set' do
        response, errors = formatted_response(
          query(in_house_installation: true, connection_costs: connection_cost_str),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(response.project).to be_nil
        expect(errors).to eq([t('projects.transition.missing_inhouse_installation_details')])
        expect(project.reload.status).to eq('technical_analysis')
      end
    end

    context 'when in house installation is not selected' do
      it 'throws error if in house details are set' do
        response, errors = formatted_response(
          query(set_installation_detail: true, connection_costs: connection_cost_str),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(response.project).to be_nil
        expect(errors).to eq([t('projects.transition.inhouse_installation_details_not_supported')])
        expect(project.reload.status).to eq('technical_analysis')
      end
    end

    context 'for Prio 1 projects' do
      before do
        pct_value.update_column(:status, :prio_one)
        allow_any_instance_of(Projects::PctCost).to receive(:project_cost).and_return(9000) # rubocop:disable RSpec/AnyInstance
      end

      it 'updates the project to ready for offer state' do
        response, errors = formatted_response(
          query(connection_costs: connection_cost_str),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(errors).to be_nil
        expect(response.project.status).to eq('ready_for_offer')

        expect(project.default_label_group.reload.label_list).to include('Prio 1')
      end
    end

    # Test for `Prio 1` projects is already available.
    context 'for On Hold projects' do
      before { pct_value.update_column(:status, :on_hold) }

      it 'updates the project to technical analysis completed' do
        response, errors = formatted_response(
          query(connection_costs: connection_cost_str),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(errors).to be_nil
        expect(response.project.status).to eq('technical_analysis_completed')

        expect(project.default_label_group.reload.label_list).to include('On Hold')
      end
    end

    context 'for marketing_only projects' do
      before { project.update_column(:category, :marketing_only) }

      it 'transitions the project to commercialization state' do
        response, errors = formatted_response(
          query(connection_costs: connection_cost_str),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(errors).to be_nil
        expect(response.project.status).to eq('commercialization')
      end
    end

    context 'with inadequate fields for calculating PCT' do
      before { penetration.update_column(:zip, '1198') }

      it 'responds with error' do
        response, errors = formatted_response(
          query(connection_costs: connection_cost_str),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(response.project).to be_nil
        expect(errors).to eq(
          [
            t('projects.transition.error_in_pct_calculation',
              error: "Penetration #{t('projects.transition.penetration_missing')}").to_s
          ]
        )
      end
    end

    context 'when PCT Value for priority lookup is missing' do
      before { pct_value.pct_month.update_column(:max, 1) }

      it 'responds with error' do
        response, errors = formatted_response(
          query(connection_costs: connection_cost_str),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(response.project).to be_nil
        expect(errors).to eq(
          [
            t('projects.transition.error_while_adding_label',
              error: "undefined method `status' for nil:NilClass").to_s
          ]
        )
      end
    end

    context 'when payback period is system generated' do
      let!(:connection_cost) { create(:connection_cost, project: project) }

      before { create(:projects_pct_cost, connection_cost: connection_cost, payback_period: 498) }

      it 'recalculates payback period' do
        _response, errors = formatted_response(
          query(connection_costs: connection_cost_str),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(errors).to be_nil
        expect(connection_cost.reload.pct_cost.payback_period).to be(25.42336309523809)
      end
    end

    context 'when payback period is manually set' do
      let!(:connection_cost) { create(:connection_cost, project: project) }

      before do
        pct_value.pct_month.update_column(:max, 498)
        create(:projects_pct_cost, :manually_set_payback_period, connection_cost: connection_cost, payback_period: 497)
      end

      it 'does not recalculate the payback period' do
        _response, errors = formatted_response(
          query(connection_costs: connection_cost_str),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(errors).to be_nil
        expect(connection_cost.reload.pct_cost.payback_period).to be(497.0)
      end
    end

    context 'when lease Line access technology is selected for standard projects' do
      it 'sets the project priority directly to prio 1' do
        response, errors = formatted_response(
          query(
            connection_costs: '{ connectionType: "hfc", costType: "standard" }',
            access_technology: 'lease_line'
          ),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(errors).to be_nil
        expect(response.project.status).to eq('ready_for_offer')
      end
    end

    context 'when lease line access technology is selected for complex projects' do
      before { project.update_column(:category, :complex) }

      it 'sets the project priority directly to prio 1' do
        response, errors = formatted_response(
          query(
            set_pct_cost: true,
            connection_costs: '
              {
                connectionType: "hfc",
                costType: "standard"
              },
              {
                connectionType: "ftth",
                costType: "standard"
              }
            ',
            access_technology: 'lease_line'
          ),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(errors).to be_nil
        expect(response.project.status).to eq('ready_for_offer')
      end
    end
  end

  def installation_detail(set_installation_detail)
    return unless set_installation_detail

    'installationDetail: { sockets: 13 builder: "ll" }'
  end

  def connection_costs(args)
    return unless args[:connection_costs]

    "connectionCosts: [#{args[:connection_costs]}]"
  end

  def query(args = {})
    access_technology = args[:access_technology] || :hfc
    in_house_installation = args[:in_house_installation] || false

    <<~GQL
      mutation {
        transitionToTechnicalAnalysisCompleted(
          input: {
            attributes: {
              id: "#{project.id}"
              accessTechnology: "#{access_technology}"
              inHouseInstallation: #{in_house_installation}
              competitionId: "#{competition.id}"
              constructionType: "new_construction"
              customerRequest: false
              fileUpload: false
              buildingType: "efh"
              priority: "proactive"
              cableInstallations: "FTTH, Coax"
              verdicts: { technical_analysis_completed: "This projects looks feasible with the current resources." }
              #{connection_costs(args)}
              #{installation_detail(args[:set_installation_detail])}
            }
          }
        )
        {
          project {
            id status verdicts cableInstallations
            connectionCosts { costType connectionType }
          }
        }
      }
    GQL
  end
end
