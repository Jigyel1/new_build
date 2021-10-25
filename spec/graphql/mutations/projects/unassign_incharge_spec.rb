# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UnassignIncharge do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project, incharge: kam) }

  describe '.resolve' do
    context 'with permissions' do # when the user is the project inchage
      it 'unassigns oneself from the project' do
        response, errors = formatted_response(query, current_user: kam, key: :unassignProjectIncharge)
        expect(errors).to be_nil
        expect(response.project.incharge).to be_nil
      end
    end

    context 'without permissions' do # when user is not the project incharge
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: super_user, key: :unassignProjectIncharge)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        unassignProjectIncharge( input: { id: "#{project.id}" } )
        { project { incharge { id name email } } }
      }
    GQL
  end
end
