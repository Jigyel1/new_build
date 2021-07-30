# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::ProjectCostResolver do
  let_it_be(:project_cost) { create(:admin_toolkit_project_cost, arpu: 50, standard: 10_500) }

  describe '.resolve' do
    context 'for admins' do
      let_it_be(:super_user) { create(:user, :super_user) }

      it 'returns the project cost' do
        response, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(response.adminToolkitProjectCost).to have_attributes(arpu: '50.0', standard: '10500.0')
      end
    end

    context 'for non admins' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam)
        expect(response.adminToolkitProjectCost).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      query {
        adminToolkitProjectCost {
          id arpu standard
        }
      }
    GQL
  end
end
