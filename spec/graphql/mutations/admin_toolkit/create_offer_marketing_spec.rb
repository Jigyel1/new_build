# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::CreateOfferMarketing do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:params) { { activity_name: { en: 'Test' }, value: 1234 } }

  describe '.resolve' do
    context 'with permissions' do
      it 'creates the offer_marketing record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createOfferMarketing)
        expect(errors).to be_nil
        expect(OpenStruct.new(response.offerMarketing)).to have_attributes(
          activityName: { en: 'Test' },
          value: 1234.0
        )
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :createOfferMarketing)
        expect(response.offerMarketing).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation{
        createOfferMarketing(input: {
        attributes: {
          activityName: { en: #{args[:activity_name][:en]} },
          value: #{args[:value]}
        }
        }){ offerMarketing { activityName value } }
      }
    GQL
  end
end
