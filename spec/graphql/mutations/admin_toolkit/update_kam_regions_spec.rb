# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateKamRegions do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_b) { create(:user, :kam) }
  let_it_be(:kam_region) { create(:admin_toolkit_kam_region, kam: kam) }
  let_it_be(:kam_region_b) { create(:admin_toolkit_kam_region, name: 'Romandie') }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { kam_id: kam_b.id } }

      it 'updates the kam region record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateKamRegions)
        expect(errors).to be_nil
        expect(response.status).to be(true)

        expect(kam_region.reload.kam_id).to eq(kam_b.id)
        expect(kam_region_b.reload.kam_id).to eq(kam_b.id)
      end
    end

    context 'with blank kam id' do
      before { kam_region_b.update_column(:kam_id, kam.id) }

      let!(:params) { { kam_id: nil } }

      it 'un assigns the KAM from that region' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateKamRegions)
        expect(errors).to be_nil
        expect(response.status).to be(true)

        expect(kam_region_b.reload.kam_id).to be_nil
      end
    end

    context 'with kam_id of a non KAM user' do
      let!(:params) { { kam_id: super_user.id } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateKamRegions)
        expect(response.status).to be_nil
        expect(errors).to match_array([t('admin_toolkit.invalid_kam')])
      end
    end

    context 'without permissions' do
      let!(:params) { { kam_id: kam_b.id } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateKamRegions)
        expect(response.kamRegion).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateKamRegions(
          input: {
            attributes: [
              {
                id: "#{kam_region.id}"
                kamId: "#{kam_b.id}"
              },
              {
                id: "#{kam_region_b.id}"
                kamId: "#{args[:kam_id]}"
              }
            ]
          }
        )
        { status }
      }
    GQL
  end
end