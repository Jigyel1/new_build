# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::DeleteKamMapping do
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_mapping) { create(:admin_toolkit_kam_mapping, kam: kam) }

  describe '.resolve' do
    context 'with permissions' do
      let_it_be(:super_user) { create(:user, :super_user) }

      it 'deletes the kam mapping' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteKamMapping)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect { AdminToolkit::KamMapping.find(kam_mapping.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deleteKamMapping)
        expect(response.kamMapping).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deleteKamMapping( input: { id: "#{kam_mapping.id}" } )
        { status }
      }
    GQL
  end
end
