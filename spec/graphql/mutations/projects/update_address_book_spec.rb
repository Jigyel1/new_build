# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UpdateAddressBook do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:address_book) { create(:address_book, project: project) }
  let_it_be(:address) { create(:address, addressable: address_book) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { type: :architect } }

      it 'updates the address book' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateAddressBook)
        expect(errors).to be_nil
        expect(response.addressBook).to have_attributes(
          displayName: 'Architect',
          type: 'architect'
        )

        expect(response.addressBook.address).to have_attributes(
          street: 'Hayes Skyway',
          streetNo: '6512',
          city: 'Barrowsport',
          zip: '8008'
        )
      end
    end

    describe 'for custom address books' do
      context 'without a display name' do
        let!(:params) { { type: :others } }

        it 'responds with error' do
          response, errors = formatted_response(query(params), current_user: super_user, key: :updateAddressBook)
          expect(response.address_book).to be_nil
          expect(errors).to eq(["Display name #{t('errors.messages.blank')}"])
        end
      end

      context 'with a display name' do
        let!(:params) { { type: :others, display_name: 'Bauingenieur' } }

        it 'updates the address book' do
          response, errors = formatted_response(query(params), current_user: super_user, key: :updateAddressBook)
          expect(errors).to be_nil
          expect(response.addressBook).to have_attributes(
            displayName: 'Bauingenieur',
            type: 'others'
          )
        end
      end
    end

    context 'with invalid params' do
      let!(:params) { { type: 'Invalid Type' } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateAddressBook)
        expect(response.address_book).to be_nil
        expect(errors).to eq(["'Invalid Type' is not a valid type"])
      end
    end

    context 'without permissions' do
      let!(:params) { { type: :investor } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: create(:user, :presales),
                                                             key: :updateAddressBook)
        expect(response.address_book).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def address
    <<~ADDRESS
      address: {
        id: "#{address_book.address.id}"
        street: "Hayes Skyway"
        streetNo: "6512"
        city: "Barrowsport"
        zip: "8008"
      }
    ADDRESS
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateAddressBook(
          input: {
            attributes: {
              id: "#{address_book.id}"
              type: "#{args[:type]}"
              displayName: "#{args[:display_name]}"
              #{address}
            }
          }
        )
        {
          addressBook {
            id type name company language email website phone mobile displayName
            address { id streetNo street city zip}
          }
        }
      }
    GQL
  end
end
