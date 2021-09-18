require 'rails_helper'

describe Mutations::Projects::TransitionToArchived do
  let_it_be(:management) { create(:user, :management) }
  let_it_be(:project) { create(:project, :technical_analysis_completed) }

  describe '.resolve' do
    context 'for standard projects' do
      context 'with permissions' do
        it 'updates project status' do
          response, errors = formatted_response(query, current_user: management, key: :transitionToArchived)
          expect(errors).to be_nil
          expect(response.project.status).to eq('archived')
          expect(response.project.verdicts).to have_attributes(technical_analysis_completed: 'This project is no longer active')
        end
      end

      context 'without permissions' do
        let_it_be(:kam) { create(:user, :kam) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :transitionToArchived)
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
        transitionToArchived(
          input: {
            attributes: {
              id: "#{project.id}"
              verdict: "This project is no longer active"
            }
          }
        )
        { project { id status verdicts } }
      }
    GQL
  end
end
