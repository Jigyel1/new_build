# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::CreateKamInvestor do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:investor_id) { '8741a6d80de7f8d70c1a027c1fa1eab2' }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { kam_id: kam.id, investor_id: investor_id } }

      it 'creates the kam investor' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createKamInvestor)
        expect(errors).to be_nil
        kam_investor = response.kamInvestor
        expect(kam_investor.investorId).to eq(investor_id)
        expect(kam_investor.kam).to have_attributes(id: kam.id, name: kam.name)
      end
    end

    context 'with invalid params' do
      let!(:params) { { kam_id: super_user.id, investor_id: investor_id } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createKamInvestor)
        expect(response.kamInvestor).to be_nil
        expect(errors).to match_array([t('admin_toolkit.invalid_kam')])
      end
    end

    context 'without permissions' do
      let!(:kam) { create(:user, :kam) }
      let!(:params) { { kam_id: kam.id, investor_id: investor_id } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :createKamInvestor)
        expect(response.kamInvestor).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        createKamInvestor(
          input: {
            attributes: {
              investorId: "#{args[:investor_id]}"
              kamId: "#{args[:kam_id]}"
            }
          }
        )
        { kamInvestor { id investorId kam { id name } } }
      }
    GQL
  end
end
