# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::ProjectResolver do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:address) { build(:address) }
  let_it_be(:project) { create(:project, address: address) }

  describe '.resolve' do
    context 'with read permission' do
      it 'returns project details' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil

        expect(data.project).to have_attributes(
                                  id: project.id,
                                  name: project.name
                                )

        expect(data.project.address).to have_attributes(
                                          street: address.street,
                                          city: address.city,
                                          zip: address.zip
                                        )

        expect(data.project.projectNr).to start_with('2')
      end
    end

    context 'without read permission' do
      let!(:manager_commercialization) { create(:user, :manager_commercialization) }

      it 'forbids action' do
        data, errors = formatted_response(query, current_user: manager_commercialization)
        expect(data.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      query { project(id: "#{project.id}") { id name projectNr address { street city zip } } }
    GQL
  end
end
