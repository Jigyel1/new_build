# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::TransitionToReadyForOffer do
  let_it_be(:management) { create(:user, :management, with_permissions: { project: %i[ready_for_offer gt_10_000] }) }
  let_it_be(:project) { create(:project, :technical_analysis_completed) }

  describe '.resolve' do
    context 'with permissions' do
      it 'updates project status' do
        response, errors = formatted_response(query, current_user: management, key: :transitionToReadyForOffer)
        expect(errors).to be_nil
        expect(response.project.status).to eq('ready_for_offer')
        expect(response.project.verdicts).to have_attributes(ready_for_offer: 'Please upload the offer docs.')
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
      let_it_be(:project_pct_cost) { create(:projects_pct_cost, project: project, project_cost: 10_000.29) }

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
        let_it_be(:admin) { create(:user, :administrator, with_permissions: { project: %i[ready_for_offer] }) }

        it 'forbids action' do
          response, errors = formatted_response(
            query,
            current_user: admin,
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
              verdicts: { ready_for_offer: "Please upload the offer docs." }
            }
          }
        )
        { project { id status verdicts } }
      }
    GQL
  end
end
