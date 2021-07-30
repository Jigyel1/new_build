# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::DeleteKamInvestor do
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_investor) { create(:admin_toolkit_kam_investor, kam: kam) }

  describe '.resolve' do
    context 'with permissions' do
      let_it_be(:super_user) { create(:user, :super_user) }

      it 'deletes the kam investor' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteKamInvestor)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect { AdminToolkit::KamInvestor.find(kam_investor.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deleteKamInvestor)
        expect(response.kamInvestor).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deleteKamInvestor( input: { id: "#{kam_investor.id}" } )
        { status }
      }
    GQL
  end
end
