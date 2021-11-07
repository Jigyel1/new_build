# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::SaveDraft do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }

  describe '.resolve' do
    it "updates project's draft version" do
      response, errors = formatted_response(query, current_user: super_user, key: :saveDraft)
      expect(errors).to be_nil
      expect(response.project.draftVersion).to have_attributes(category: 'complex', lease_cost: 1198.87)
    end
  end

  def query
    <<~GQL
      mutation {
        saveDraft(
          input: {
            attributes: { id: "#{project.id}" draftVersion: { category: "complex", lease_cost: 1198.87 } }
          }
        )
        { project { id draftVersion } }
      }
    GQL
  end
end
