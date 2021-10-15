# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::TransitionToTechnicalAnalysisCompleted do
  let_it_be(:zip) { '1101' }
  let_it_be(:project_cost) { create(:admin_toolkit_project_cost, standard: 99_987) }
  let_it_be(:kam_region) { create(:admin_toolkit_kam_region) }
  let_it_be(:label_group_a) { create(:admin_toolkit_label_group, :technical_analysis_completed) }
  let_it_be(:label_group_b) { create(:admin_toolkit_label_group, :ready_for_offer) }

  let_it_be(:competition) { create(:admin_toolkit_competition) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration, zip: zip, kam_region: kam_region, rate: 4.56) }
  let_it_be(:penetration_competition) do
    create(:penetration_competition, penetration: penetration, competition: competition)
  end

  let_it_be(:pct_value) do
    create(
      :admin_toolkit_pct_value,
      :prio_two,
      pct_month: create(:admin_toolkit_pct_month, min: 10, max: 17),
      pct_cost: create(:admin_toolkit_pct_cost, min: 1187, max: 100_000)
    )
  end

  let_it_be(:super_user) do
    create(
      :user,
      :super_user,
      with_permissions: {
        project: %i[
          complex
          technical_analysis_completed
          ready_for_offer
        ]
      }
    )
  end

  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:management) { create(:user, :management) }
  let_it_be(:address) { build(:address, zip: zip) }
  let_it_be(:project) { create(:project, :technical_analysis, address: address) }
  let_it_be(:building) { create(:building, apartments_count: 30, project: project) }

  describe '.resolve' do
    context 'with permissions' do
      before_all { project.update_column(:category, :complex) }
      let_it_be(:params) { { set_pct_cost: true } }

      it 'updates project status' do
        response, errors = formatted_response(
          query(params),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(errors).to be_nil
        expect(response.project.status).to eq('technical_analysis_completed')
        expect(response.project.verdicts).to have_attributes(
          technical_analysis_completed: 'This projects looks feasible with the current resources.'
        )

        expect(project.default_label_group.reload.label_list).to include('Prio 2')
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam,
                                                     key: :transitionToTechnicalAnalysisCompleted)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
        expect(project.reload.status).to eq('technical_analysis')
      end
    end

    context 'when standard cost is applicable' do
      it 'throws error when preferred access technology is set to FTTH' do
        response, errors = formatted_response(
          query(standard_cost_applicable: true, access_technology: :ftth),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(response.project).to be_nil
        expect(errors).to eq([t('projects.transition.ftth_not_supported')])
        expect(project.reload.status).to eq('technical_analysis')
      end

      it 'throws error when access technology cost is set' do
        response, errors = formatted_response(
          query(standard_cost_applicable: true, set_access_tech_cost: true),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(response.project).to be_nil
        expect(errors).to eq([t('projects.transition.access_tech_cost_not_supported')])
        expect(project.reload.status).to eq('technical_analysis')
      end
    end

    context 'when in house installation is selected' do
      it 'throws error if in house details are not set' do
        response, errors = formatted_response(
          query(in_house_installation: true),
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
          query(set_installation_detail: true),
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(response.project).to be_nil
        expect(errors).to eq([t('projects.transition.inhouse_installation_details_not_supported')])
        expect(project.reload.status).to eq('technical_analysis')
      end
    end

    context 'for Prio 1 projects' do
      before { pct_value.update_column(:status, :prio_one) }

      it 'updates the project to ready for offer state' do
        response, errors = formatted_response(
          query,
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
          query,
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(errors).to be_nil
        expect(response.project.status).to eq('technical_analysis_completed')

        expect(project.default_label_group.reload.label_list).to include('On Hold')
      end
    end

    context 'with inadequate fields for calculating PCT' do
      before { penetration.update_column(:zip, '1198') }

      it 'responds with error' do
        response, errors = formatted_response(
          query,
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
      before { pct_value.pct_month.update_column(:max, 13) }

      it 'responds with error' do
        response, errors = formatted_response(
          query,
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
      let_it_be(:project_pct_cost) { create(:projects_pct_cost, project: project, payback_period: 498) }

      it 'recalculates payback period' do
        _response, errors = formatted_response(
          query,
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(errors).to be(nil)
        expect(project.reload.pct_cost.payback_period).to be(17)
      end
    end

    context 'when payback period is manually set' do
      before do
        pct_value.pct_month.update_column(:max, 498)
        create(:projects_pct_cost, :manually_set_payback_period, project: project, payback_period: 498)
      end

      it 'does not recalculate the payback period' do
        _response, errors = formatted_response(
          query,
          current_user: super_user,
          key: :transitionToTechnicalAnalysisCompleted
        )
        expect(errors).to be(nil)
        expect(project.reload.pct_cost.payback_period).to be(498)
      end
    end
  end

  def pct_cost(set_pct_cost)
    return unless set_pct_cost

    'pctCost: { projectConnectionCost: 99998.56 }'
  end

  def installation_detail(set_installation_detail)
    return unless set_installation_detail

    'installationDetail: { sockets: 13 builder: "ll" }'
  end

  def access_tech_cost(set_access_tech_cost)
    return unless set_access_tech_cost

    <<~ACCESS_TECH_COST
      accessTechCost: {
        hfcOnPremiseCost: 119
        hfcOffPremiseCost: 1198
        lwlOnPremiseCost: 98
        lwlOffPremiseCost: 999
      }
    ACCESS_TECH_COST
  end

  def query(args = {})
    access_technology = args[:access_technology] || :hfc
    standard_cost_applicable = args[:standard_cost_applicable] || false
    in_house_installation = args[:in_house_installation] || false

    <<~GQL
      mutation {
        transitionToTechnicalAnalysisCompleted(
          input: {
            attributes: {
              id: "#{project.id}"
              standardCostApplicable: #{standard_cost_applicable}
              accessTechnology: "#{access_technology}"
              inHouseInstallation: #{in_house_installation}
              competitionId: "#{competition.id}"
              constructionType: "b2b_new"
              customerRequest: false
              priority: "proactive"
              verdicts: { technical_analysis_completed: "This projects looks feasible with the current resources." }
              #{access_tech_cost(args[:set_access_tech_cost])}
              #{installation_detail(args[:set_installation_detail])}
              #{pct_cost(args[:set_pct_cost])}
            }
          }
        )
        { project { id status verdicts } }
      }
    GQL
  end
end
