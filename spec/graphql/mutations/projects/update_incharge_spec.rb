# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UpdateIncharge do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }

  describe '.resolve' do
    context 'with permissions' do
      it 'updates the task' do
        response, errors = formatted_response(query, current_user: super_user, key: :updateProjectIncharge)
        expect(errors).to be_nil
        expect(response.project.incharge).to have_attributes(id: kam.id, email: kam.email, name: kam.name)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :updateProjectIncharge)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        updateProjectIncharge( input: { attributes: { projectId: "#{project.id}" inchargeId: "#{kam.id}" } } )
        { project { incharge { id name email } } }
      }
    GQL
  end
end
