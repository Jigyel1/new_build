# frozen_string_literal: true

require 'rails_helper'

module Projects
  module UnarchiveSpecHelper
    def transitions(project, states)
      states.each { |state| project.update!(status: state) }
    end
  end
end

describe Mutations::Projects::UnarchiveProject do
  include Projects::UnarchiveSpecHelper

  let_it_be(:super_user) do
    create(
      :user,
      :super_user,
      with_permissions: { project: %i[open technical_analysis technical_analysis_completed ready_for_offer] }
    )
  end

  let_it_be(:project) { create(:project) }
  # let_it_be(:pct_value) do
  #   create(
  #     :admin_toolkit_pct_value,
  #     :prio_two,
  #     pct_month: create(:admin_toolkit_pct_month, min: 0, max: 507),
  #     pct_cost: create(:admin_toolkit_pct_cost, min: 10, max: 100_000)
  #   )
  # end

  describe '.resolve' do
    context 'when the previous state was open' do
      before_all { transitions(project, %i[archived]) }

      context 'with permissions' do
        it 'reverts to open' do
          response, errors = formatted_response(query, current_user: super_user, key: :unarchiveProject)
          expect(errors).to be_nil
          expect(response.project.status).to eq('open')
        end
      end

      context 'without permissions' do
        let_it_be(:kam) { create(:user, :kam) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :unarchiveProject)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('archived')
        end
      end
    end

    context 'when the previous state was technical analysis' do
      before_all { transitions(project, %i[technical_analysis archived]) }

      context 'with permissions' do
        it 'reverts to technical analysis' do
          response, errors = formatted_response(query, current_user: super_user, key: :unarchiveProject)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis')
        end
      end

      context 'without permissions' do
        let_it_be(:kam) { create(:user, :kam) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :unarchiveProject)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('archived')
        end
      end
    end

    context 'when the previous state was technical analysis completed' do
      before_all { transitions(project, %i[technical_analysis_completed archived]) }

      context 'with permissions' do
        it 'reverts to technical analysis completed' do
          response, errors = formatted_response(query, current_user: super_user, key: :unarchiveProject)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis_completed')
        end
      end

      context 'without permissions' do
        let_it_be(:kam) { create(:user, :kam) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :unarchiveProject)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('archived')
        end
      end
    end

    context 'when the previous state was ready for offer' do
      before_all { transitions(project, %i[ready_for_offer archived]) }

      context 'with permissions' do
        it 'reverts to technical analysis completed' do
          response, errors = formatted_response(query, current_user: super_user, key: :unarchiveProject)
          expect(errors).to be_nil
          expect(response.project.status).to eq('ready_for_offer')
        end
      end

      context 'without permissions' do
        let_it_be(:kam) { create(:user, :kam) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :unarchiveProject)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('archived')
        end
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
