require 'rails_helper'

describe Mutations::Projects::RevertTransition do
  let_it_be(:management) { create(:user, :management) }
  let_it_be(:project) { create(:project) }
  let_it_be(:pct_value) do
    create(
      :admin_toolkit_pct_value,
      :prio_two,
      pct_month: create(:admin_toolkit_pct_month, min: 0, max: 507),
      pct_cost: create(:admin_toolkit_pct_cost, min: 10, max: 100000)
    )
  end

  describe '.resolve' do
    context 'for projects with status - technical analysis' do
      before_all { project.update_column(:status, :technical_analysis) }

      context 'with permissions' do
        it 'reverts to open' do
          response, errors = formatted_response(query, current_user: management, key: :revertProjectTransition)
          expect(errors).to be_nil
          expect(response.project.status).to eq('open')
        end
      end

      context 'without permissions' do
        let_it_be(:kam) { create(:user, :kam) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :revertProjectTransition)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('technical_analysis')
        end
      end
    end

    context 'for projects with status - technical analysis completed' do
      before_all { project.update_column(:status, :technical_analysis_completed) }

      context 'with permissions' do
        it 'reverts to technical analysis' do
          response, errors = formatted_response(query, current_user: management, key: :revertProjectTransition)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis')
        end
      end

      context 'without permissions' do
        let_it_be(:kam) { create(:user, :kam) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :revertProjectTransition)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('technical_analysis_completed')
        end
      end
    end

    context 'for projects with status - ready for offer' do
      before_all { project.update_column(:status, :ready_for_offer) }

      context 'with permissions' do # prio 1 projects
        before { allow_any_instance_of(Projects::StateMachine).to receive(:prio_one?).and_return(true) }

        it 'reverts to technical analysis' do
          response, errors = formatted_response(query, current_user: management, key: :revertProjectTransition)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis')
        end
      end

      context 'without permissions' do
        let_it_be(:kam) { create(:user, :kam) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :revertProjectTransition)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('ready_for_offer')
        end
      end

      context 'for prio 2 projects' do
        let_it_be(:project_pct_cost) { create(:projects_pct_cost, project: project, payback_period: 498) }

        it 'reverts to technical analysis completed' do
          response, errors = formatted_response(query, current_user: management, key: :revertProjectTransition)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis_completed')
        end
      end

      context 'for on hold projects' do
        before { pct_value.update_column(:status, :on_hold) }
        let_it_be(:project_pct_cost) { create(:projects_pct_cost, project: project, payback_period: 498) }

        it 'reverts to technical analysis completed' do
          response, errors = formatted_response(query, current_user: management, key: :revertProjectTransition)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis_completed')
        end
      end
    end
  end

  def query
    <<~GQL
      mutation {
        revertProjectTransition(
          input: {
            attributes: {
              id: "#{project.id}"
            }
          }
        )
        { project { id status } }
      }
    GQL
  end
end
