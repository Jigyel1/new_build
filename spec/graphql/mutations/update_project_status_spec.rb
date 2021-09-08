require 'rails_helper'

describe Mutations::UpdateProjectStatus do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }

  describe '.resolve' do
    describe '#technical analysis' do
      let_it_be(:params) {{ status: :technical_analysis }}

      context 'with permissions' do
        it 'updates project status' do
          response, errors = formatted_response(query(params), current_user: super_user, key: :updateProjectStatus)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis')
        end
      end

      context 'without permissions' do
        it 'forbids action' do
          response, errors = formatted_response(query(params), current_user: kam, key: :updateProjectStatus)
          expect(response.user).to be_nil
          expect(errors).to eq([t('projects.invalid_transition')])
          expect(project.reload.status).to eq('open')
        end
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateProjectStatus(
          input: {
            attributes: {
              id: "#{project.id}"
              status: "#{args[:status]}"
            }
          }
        )
        { project { id status } }
      }
    GQL
  end
end
