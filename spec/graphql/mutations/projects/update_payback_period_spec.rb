# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UpdatePaybackPeriod do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:connection_cost) { create(:connection_cost, project: project) }

  describe '.resolve' do
    context 'with permissions' do
      it 'updates the payback period for the project' do
        response, errors = formatted_response(query, current_user: super_user, key: :updatePaybackPeriod)
        expect(errors).to be_nil

        connection_costs = response.project.connectionCosts
        expect(OpenStruct.new(connection_costs.first[:pctCost])).to have_attributes(
          paybackPeriod: 450,
          systemGeneratedPaybackPeriod: false
        )
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :updatePaybackPeriod)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'without a pct cost' do
      it 'creates a new association and updates the respective field' do
        response, errors = formatted_response(query, current_user: super_user, key: :updatePaybackPeriod)
        expect(errors).to be_nil
        connection_costs = response.project.connectionCosts
        expect(OpenStruct.new(connection_costs.first[:pctCost])).to have_attributes(paybackPeriod: 450)
      end
    end
  end

  def query
    <<~GQL
      mutation {
        updatePaybackPeriod( input: { attributes: { connectionCostId: "#{connection_cost.id}" months: 450 } } )
        { project { connectionCosts { pctCost { paybackPeriod systemGeneratedPaybackPeriod } } } }
      }
    GQL
  end
end
