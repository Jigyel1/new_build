# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::TransitionToTechnicalAnalysis do
  let_it_be(:team_expert) { create(:user, :team_expert, with_permissions: { project: :technical_analysis }) }
  let_it_be(:project) { create(:project) }

  describe '.resolve' do
    context 'with permissions' do
      it 'updates project status' do
        response, errors = formatted_response(query, current_user: team_expert, key: :transitionToTechnicalAnalysis)
        expect(errors).to be_nil
        expect(response.project.status).to eq('technical_analysis')

        expect(project.reload.incharge).to eq(team_expert)
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :transitionToTechnicalAnalysis)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
        expect(project.reload.status).to eq('open')
      end
    end
  end

  def query
    <<~GQL
      mutation {
        transitionToTechnicalAnalysis( input: { attributes: { id: "#{project.id}" } } )
        { project { id status } }
      }
    GQL
  end
end
