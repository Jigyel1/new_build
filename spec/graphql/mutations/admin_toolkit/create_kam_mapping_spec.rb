# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::CreateKamMapping do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { kam_id: kam.id, investor_id: '8741a6d80de7f8d70c1a027c1fa1eab2' } }

      it 'creates the kam mapping' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createKamMapping)
        expect(errors).to be_nil
        kam_mapping = response.kamMapping
        expect(kam_mapping.investorId).to eq('8741a6d80de7f8d70c1a027c1fa1eab2')
        expect(kam_mapping.kam).to have_attributes(id: kam.id, name: kam.name)
      end
    end

    context 'with invalid params' do
      let!(:params) { { kam_id: super_user.id, investor_id: '8741a6d80de7f8d70c1a027c1fa1eab2' } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createKamMapping)
        expect(response.kamMapping).to be_nil
        expect(errors).to match_array([t('admin_toolkit.kam_mapping.invalid_kam')])
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }
      let!(:params) { { kam_id: kam.id, investor_id: '8741a6d80de7f8d70c1a027c1fa1eab2' } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :createKamMapping)
        expect(response.kamMapping).to be_nil
        expect(errors).to match_array(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        createKamMapping(
          input: {
            attributes: {
              investorId: "#{args[:investor_id]}"
              kamId: "#{args[:kam_id]}"
            }
          }
        )
        { kamMapping { id investorId kam { id name } } }
      }
    GQL
  end
end
