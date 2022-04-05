# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UpdateConfirmationStatus do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :confirm }) }
  let_it_be(:manager_commercialization) { create(:user, :manager_commercialization) }
  let_it_be(:project) { create(:project, :standard) }

  describe '.resolve' do
    context 'with permissions' do
      it "updates project's category" do
        response, errors = formatted_response(query, current_user: super_user, key: :updateConfirmationStatus)
        expect(errors).to be_nil
        expect(response.project.confirmationStatus).to eq('new_offer')
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(
          query,
          current_user: manager_commercialization,
          key: :updateConfirmationStatus
        )
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        updateConfirmationStatus(
          input: { attributes: { projectId: "#{project.id}", confirmationStatus: "new_offer" } }
        ) { project { id confirmationStatus } }
       }
    GQL
  end
end
