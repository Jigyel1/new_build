# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::DeletePenetration do
  let_it_be(:kam_region) { create(:admin_toolkit_kam_region) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration, kam_region: kam_region) }

  describe '.resolve' do
    context 'with permissions' do
      let_it_be(:super_user) { create(:user, :super_user) }

      it 'deletes the penetration record' do
        response, errors = formatted_response(query, current_user: super_user, key: :deletePenetration)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect { AdminToolkit::Penetration.find(penetration.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deletePenetration)
        expect(response.penetration).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deletePenetration( input: { id: "#{penetration.id}" } )
        { status }
      }
    GQL
  end
end
