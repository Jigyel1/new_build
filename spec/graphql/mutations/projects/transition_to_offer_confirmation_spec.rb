# frozen_string_literal: true

require 'rails_helper'

describe Mutations::Projects::TransitionToOfferConfirmation do
  let_it_be(:super_user) do
    create(:user, :super_user, with_permissions: { project: %i[offer_confirmation] })
  end
  let_it_be(:project) { create(:project, :ready_for_offer, :ftth) }

  describe '.resolve' do
    context 'with permissions' do
      it 'updates project status' do
        response, errors = formatted_response(query, current_user: super_user, key: :transitionToOfferConfirmation)
        expect(errors).to be_nil
        expect(response.project.status).to eq('offer_confirmation')
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :transitionToReadyForOffer)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
        expect(project.reload.status).to eq('ready_for_offer')
      end
    end
  end

  def query
    <<~GQL
      mutation {
        transitionToOfferConfirmation(
          input: {
            attributes: {
              id: "#{project.id}"
            }
          }
        )
        { project { id status } }
      }
    GQL
  end
end
