# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::TransitionToReadyForOffer do
  let_it_be(:management) { create(:user, :management, with_permissions: { project: %i[ready_for_offer gt_10_000] }) }
  let_it_be(:project) { create(:project, :technical_analysis_completed, :hfc) }

  before do
    allow_any_instance_of(Projects::StateMachine).to receive(:pct_value).and_return( # rubocop:disable RSpec/AnyInstance
      instance_double(AdminToolkit::PctValue, status: :prio_one)
    )
  end

  describe '.resolve' do
    context 'with permissions' do
      it 'updates project status' do
        response, errors = formatted_response(query, current_user: management, key: :transitionToReadyForOffer)
        expect(errors).to be_nil
        expect(response.project).to have_attributes(
          status: 'ready_for_offer',
          priorityTac: 'reactive',
          accessTechnologyTac: 'ftth'
        )
        expect(response.project.verdicts).to have_attributes(
          technical_analysis_completed: 'Please upload the offer docs.'
        )
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :transitionToReadyForOffer)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
        expect(project.reload.status).to eq('technical_analysis_completed')
      end
    end

    context 'when the project cost exceeds 10K CHF' do
      let_it_be(:connection_cost) { create(:connection_cost, project: project) }
      let_it_be(:project_pct_cost) do
        create(:projects_pct_cost, connection_cost: connection_cost, project_cost: 10_000.29)
      end

      context 'with permissions' do
        it 'allows action' do
          response, errors = formatted_response(
            query,
            current_user: management,
            key: :transitionToReadyForOffer
          )
          expect(errors).to be_nil
          expect(response.project.status).to eq('ready_for_offer')
        end
      end

      context 'without permissions' do
        let_it_be(:manager) { create(:user, :manager_nbo_kam, with_permissions: { project: %i[ready_for_offer] }) }

        it 'forbids action' do
          response, errors = formatted_response(
            query,
            current_user: manager,
            key: :transitionToReadyForOffer
          )

          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('technical_analysis_completed')
        end
      end
    end
  end

  def query
    <<~GQL
      mutation {
        transitionToReadyForOffer(
          input: {
            attributes: {
              id: "#{project.id}"
              priorityTac: "reactive"
              accessTechnologyTac: "ftth"
              verdicts: { ready_for_offer: "Please upload the offer docs." }
            }
          }
        )
        { project { id status verdicts priorityTac accessTechnologyTac } }
      }
    GQL
  end
end
