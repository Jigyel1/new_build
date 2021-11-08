# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::DeleteAddressBook do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project) }
  let_it_be(:address_book) { create(:address_book, project: project) }

  describe '.resolve' do
    context 'with permissions' do
      it 'deletes the task' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteAddressBook)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect { Projects::AddressBook.find(address_book.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without permissions' do
      let!(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deleteAddressBook)
        expect(response.task).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deleteAddressBook(input: { id: "#{address_book.id}" } )
        { status }
      }
    GQL
  end
end
