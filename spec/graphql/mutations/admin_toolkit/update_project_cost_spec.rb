# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateProjectCost do
  let_it_be(:project_cost) { create(:admin_toolkit_project_cost) }
  let!(:params) { { project_cost_id: project_cost.id, arpu: 50, standard: 10_500 } }

  describe '.resolve' do
    context 'for admins' do
      it 'updates the label list' do
        response, errors = formatted_response(
          query(params),
          current_user: create(:user, :super_user),
          key: :updateProjectCost
        )

        expect(errors).to be_nil
        expect(response.projectCost).to have_attributes(
          standard: 10_500.0,
          socketInstallationRate: 75.46,
          mrcStandard: 20.0,
          mrcHighTiers: 37.0,
          highTiersProductShare: 20,
          hfcPayback: 36,
          ftthCost: 1198.55
        )
      end
    end

    context 'for non admins' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: create(:user, :kam), key: :updateProjectCost)
        expect(response.labelGroup).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateProjectCost(
          input: {
            attributes: {
              standard: #{args[:standard]}
              socketInstallationRate: 75.456
              mrcStandard: 20.0
              mrcHighTiers: 37.0
              highTiersProductShare: 20
              hfcPayback: 36
              ftthCost: 1198.55
            }
          }
        )
        {
          projectCost {
            id standard socketInstallationRate mrcStandard
            mrcHighTiers highTiersProductShare hfcPayback ftthCost
          }
        }
      }
    GQL
  end
end
