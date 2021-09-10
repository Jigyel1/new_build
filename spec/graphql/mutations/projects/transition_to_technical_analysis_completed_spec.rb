require 'rails_helper'

describe Mutations::Projects::TransitionToTechnicalAnalysis do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }

  describe '.resolve' do
    describe '#technical analysis' do
      context 'with permissions' do
        it 'updates project status' do
          response, errors = formatted_response(query, current_user: super_user, key: :transitionToTechnicalAnalysis)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis')
        end
      end

      context 'without permissions' do
        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :transitionToTechnicalAnalysis)
          expect(response.user).to be_nil
          expect(errors).to eq([t('projects.invalid_transition')])
          expect(project.reload.status).to eq('open')
        end
      end
    end
  end

  def query
    <<~GQL
      mutation {
        transitionToTechnicalAnalysis(
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
