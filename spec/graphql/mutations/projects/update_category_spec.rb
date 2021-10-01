# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UpdateCategory do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project, :standard) }

  describe '.resolve' do
    context 'with permissions' do
      it "updates project's category" do
        response, errors = formatted_response(query, current_user: super_user, key: :updateProjectCategory)
        expect(errors).to be_nil
        expect(response.project).to have_attributes(category: 'complex', systemSortedCategory: false)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :updateProjectCategory)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        updateProjectCategory( input: { attributes: { projectId: "#{project.id}" category: "complex" } } )
        { project { category systemSortedCategory } }
      }
    GQL
  end
end
