# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::RevertTransition do
  let_it_be(:incharge) { create(:user, :super_user) }
  let_it_be(:project) { create(:project, :hfc, incharge: incharge) }
  let_it_be(:pct_value) do
    create(
      :admin_toolkit_pct_value,
      :prio_two,
      pct_month: create(:admin_toolkit_pct_month, min: 0, max: 507),
      pct_cost: create(:admin_toolkit_pct_cost, min: 10, max: 100_000)
    )
  end

  describe '.resolve' do
    context 'for projects with status - technical analysis' do
      before_all { project.update_column(:status, :technical_analysis) }

      context 'with permissions' do
        let(:super_user) { create(:user, :super_user, with_permissions: { project: :technical_analysis }) }

        it 'reverts to open' do
          response, errors = formatted_response(query, current_user: super_user, key: :revertProjectTransition)
          expect(errors).to be_nil
          expect(response.project.status).to eq('open')
        end
      end

      context 'without permissions' do
        let(:super_user) { create(:user, :super_user) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: super_user, key: :revertProjectTransition)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('technical_analysis')
        end
      end
    end

    context 'for projects with status - technical analysis completed' do
      before_all { project.update_column(:status, :technical_analysis_completed) }

      context 'with permissions' do # as an incharge
        it 'reverts to technical analysis' do
          response, errors = formatted_response(query, current_user: incharge, key: :revertProjectTransition)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis')
        end
      end

      context 'without permissions' do
        let(:super_user) { create(:user, :super_user) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: super_user, key: :revertProjectTransition)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('technical_analysis_completed')
        end
      end
    end

    context 'for projects with status - ready for offer' do
      before_all { project.update_column(:status, :ready_for_offer) }
      let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :ready_for_offer }) }
      let_it_be(:connection_cost) { create(:connection_cost, project: project) }

      context 'with permissions' do # prio 1 projects
        before do
          pct_value.update_column(:status, :prio_one)
          create(:projects_pct_cost, connection_cost: connection_cost, payback_period: 15)
        end

        it 'reverts to technical analysis' do
          response, errors = formatted_response(query, current_user: super_user, key: :revertProjectTransition)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis')
        end
      end

      context 'for prio 2 projects' do
        let_it_be(:project_pct_cost) do
          create(:projects_pct_cost, connection_cost: connection_cost, payback_period: 498)
        end

        it 'reverts to technical analysis completed' do
          response, errors = formatted_response(query, current_user: super_user, key: :revertProjectTransition)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis_completed')
        end
      end

      context 'for on hold projects' do
        before { pct_value.update_column(:status, :on_hold) }

        let_it_be(:project_pct_cost) do
          create(:projects_pct_cost, connection_cost: connection_cost, payback_period: 498)
        end

        it 'reverts to technical analysis completed' do
          response, errors = formatted_response(query, current_user: super_user, key: :revertProjectTransition)
          expect(errors).to be_nil
          expect(response.project.status).to eq('technical_analysis_completed')
        end
      end

      context 'without permissions' do
        let_it_be(:kam) { create(:user, :kam) }

        it 'forbids action' do
          response, errors = formatted_response(query, current_user: kam, key: :revertProjectTransition)
          expect(response.project).to be_nil
          expect(errors).to eq(['Not Authorized'])
          expect(project.reload.status).to eq('ready_for_offer')
        end
      end
    end

    # TODO: Please note that at this point the following are yet to be covered.
    #   - In-between state transitions - <tt>contract, contract_accepted, under_construction</tt>
    #   - Specs are covered with the assumption that a <tt>marketing_only</tt> project
    #     can transition to <tt>commercialization</tt> from <tt>technical_analysis</tt>
    #     and vice versa without the need for user authorization.
    context 'for projects with status - commercialization' do
      before_all { project.update_columns(category: :marketing_only, status: :commercialization) }

      it 'reverts to technical analysis' do
        response, errors = formatted_response(query, current_user: incharge, key: :revertProjectTransition)
        expect(errors).to be_nil
        expect(response.project.status).to eq('technical_analysis')
      end
    end
  end

  def query
    <<~GQL
      mutation {
        revertProjectTransition( input: { attributes: { id: "#{project.id}" } } )
        { project { id status } }
      }
    GQL
  end
end
