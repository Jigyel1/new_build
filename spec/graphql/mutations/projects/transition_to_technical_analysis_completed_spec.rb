require 'rails_helper'

describe Mutations::Projects::TransitionToTechnicalAnalysisCompleted do
  let_it_be(:competition) { create(:admin_toolkit_competition) }
  let_it_be(:team_expert) { create(:user, :team_expert) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project, :technical_analysis) }

  describe '.resolve' do
    context 'for standard projects' do
      context 'with permissions' do
        it 'updates project status' do
          response, errors = formatted_response(query, current_user: team_expert, key: :transitionToTechnicalAnalysisCompleted)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis_completed')
        end
      end

      context 'without permissions' do
        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :transitionToTechnicalAnalysisCompleted)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('technical_analysis')
        end
      end
    end

    context 'for complex projects' do
      before_all { project.update_column(:category, :complex) }

      context 'with permissions' do
        let_it_be(:management) { create(:user, :management) }

        it 'updates project status' do
          response, errors = formatted_response(query, current_user: management, key: :transitionToTechnicalAnalysisCompleted)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis_completed')
        end
      end

      context 'without permissions' do
        it 'forbids action' do
          response, errors = formatted_response(query, current_user: team_expert, key: :transitionToTechnicalAnalysisCompleted)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('technical_analysis')
        end
      end
    end

    context 'when standard cost is applicable' do
      it 'throws error when preferred access technology is set to FTTH' do
        response, errors = formatted_response(
          query(standard_cost_applicable: true, access_technology: :ftth),
          current_user: team_expert,
          key: :transitionToTechnicalAnalysisCompleted
        )
        
        expect(response.project).to be_nil
        expect(errors).to eq([t('projects.transition.ftth_not_supported')])
        expect(project.reload.status).to eq('technical_analysis')
      end
    end

    context 'when standard cost is not applicable' do
      it 'throws error when access technology cost is set' do
        response, errors = formatted_response(
          query(set_access_tech_cost: true),
          current_user: team_expert,
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
          current_user: team_expert,
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
          current_user: team_expert,
          key: :transitionToTechnicalAnalysisCompleted
        )

        expect(response.project).to be_nil
        expect(errors).to eq([t('projects.transition.inhouse_installation_details_not_supported')])
        expect(project.reload.status).to eq('technical_analysis')
      end
    end
  end

  def installation_detail(set_installation_detail)
    return unless set_installation_detail

    <<~INSTALLATION_DETAIL
      installationDetail: {
        sockets: 13
        builder: "ll"
      }
    INSTALLATION_DETAIL
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

  def query(args= {})
    category = args[:category] || :standard
    access_technology = args[:access_technology] || :hfc
    standard_cost_applicable = args[:standard_cost_applicable] || false
    in_house_installation = args[:in_house_installation] || false

    <<~GQL
      mutation {
        transitionToTechnicalAnalysisCompleted(
          input: {
            attributes: {
              id: "#{project.id}"
              category: "#{category}"
              standardCostApplicable: #{standard_cost_applicable}
              accessTechnology: "#{access_technology}"
              inHouseInstallation: #{in_house_installation}
              competitionId: "#{competition.id}"
              constructionType: "b2b_new"
              customerRequest: false
              priority: "proactive"
              #{access_tech_cost(args[:set_access_tech_cost])}
              #{installation_detail(args[:set_installation_detail])}
            }
          }
        )
        { project { id status } }
      }
    GQL
  end
end
