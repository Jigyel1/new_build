# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::UnarchiveProject do
  include ProjectsTransitionSpecHelper

  let_it_be(:super_user) do
    create(
      :user,
      :super_user,
      with_permissions: { project: :archive }
    )
  end

  let_it_be(:project) { create(:project, incharge: super_user) }

  describe '.resolve' do
    context 'when the previous state was open' do
      before_all { transitions(project, %i[archived]) }

      it 'reverts to open' do
        response, errors = formatted_response(query, current_user: super_user, key: :unarchiveProject)
        expect(errors).to be_nil
        expect(response.project.status).to eq('open')
      end
    end

    context 'when the previous state was technical analysis' do
      before_all { transitions(project, %i[technical_analysis archived]) }

      it 'reverts to technical analysis' do
        response, errors = formatted_response(query, current_user: super_user, key: :unarchiveProject)
        expect(errors).to be_nil
        expect(response.project.status).to eq('technical_analysis')
      end
    end

    context 'when the previous state was technical analysis completed' do
      before_all { transitions(project, %i[technical_analysis_completed archived]) }

      it 'reverts to technical analysis completed' do
        response, errors = formatted_response(query, current_user: super_user, key: :unarchiveProject)
        expect(errors).to be_nil
        expect(response.project.status).to eq('technical_analysis_completed')
      end
    end

    context 'when the previous state was ready for offer' do
      before_all { transitions(project, %i[ready_for_offer archived]) }

      it 'reverts to technical analysis completed' do
        response, errors = formatted_response(query, current_user: super_user, key: :unarchiveProject)
        expect(errors).to be_nil
        expect(response.project.status).to eq('ready_for_offer')
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }
      before_all { transitions(project, %i[ready_for_offer archived]) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :unarchiveProject)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
        expect(project.reload.status).to eq('archived')
      end
    end
  end

  def query
    <<~GQL
      mutation {
        unarchiveProject( input: { id: "#{project.id}" } )
        { project { id status } }
      }
    GQL
  end
end
