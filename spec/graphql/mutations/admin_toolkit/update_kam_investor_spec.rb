# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateKamInvestor do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_investor) { create(:kam_investor, kam: kam) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { investor_id: 'bee799d0fcc4b4f11d5b615f8476f766' } }

      it 'updates the kam_investor record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateKamInvestor)
        expect(errors).to be_nil
        expect(response.kamInvestor.investorId).to eq('bee799d0fcc4b4f11d5b615f8476f766')
      end
    end

    context 'with blank investor id' do
      let!(:params) { { investor_id: '' } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateKamInvestor)
        expect(response.kamInvestor).to be_nil
        expect(errors).to eq(["Investor #{t('errors.messages.blank')}"])
      end
    end

    context 'with kam_id of a non KAM user' do
      let!(:params) { { kam_id: super_user.id, investor_id: 'bee799d0fcc4b4f11d5b615f8476f766' } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateKamInvestor)
        expect(response.kamInvestor).to be_nil
        expect(errors).to eq([t('admin_toolkit.invalid_kam')])
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }
      let!(:params) { { investor_id: 'bee799d0fcc4b4f11d5b615f8476f766' } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateKamInvestor)
        expect(response.kamInvestor).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    kam_id = args[:kam_id] || kam.id

    <<~GQL
      mutation {
        updateKamInvestor(
          input: {
            attributes: {
              id: "#{kam_investor.id}"
              investorId: "#{args[:investor_id]}"
              kamId: "#{kam_id}"
            }
          }
        )
        { kamInvestor { id investorId kam { id name } } }
      }
    GQL
  end
end
