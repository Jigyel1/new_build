# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::CreateAddressBook do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { type: :investor } }

      it 'creates the address book' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createAddressBook)
        expect(errors).to be_nil
        expect(response.addressBook).to have_attributes(
                                          name: 'Philips',
                                          displayName: 'Investor',
                                          type: 'Investor',
                                          company: 'Charlotte Hornets',
                                          phone: '099292922',
                                          mobile: '03393933',
                                          email: 'philips.jordan@chornets.us',
                                          website: 'charlotte-hornets.com'
                                        )

        expect(response.addressBook.address).to have_attributes(
                                                  street: "Hayes Skyway",
                                                  streetNo: "6512",
                                                  city: "Barrowsport",
                                                  zip: "8008"
                                                )
      end
    end

    describe 'for custom address books' do
      context 'without a display name' do
        let!(:params) { { type: :others } }

        it 'responds with error' do
          response, errors = formatted_response(query(params), current_user: super_user, key: :createAddressBook)
          expect(response.address_book).to be_nil
          expect(errors).to eq(["Display name #{t('errors.messages.blank')}"])
        end
      end

      context 'with a display name' do
        let!(:params) { { type: :others, display_name: 'Bauingenieur' } }

        it 'creates the address book' do
          response, errors = formatted_response(query(params), current_user: super_user, key: :createAddressBook)
          expect(errors).to be_nil
          expect(response.addressBook).to have_attributes(
                                            displayName: 'Bauingenieur',
                                            type: 'Others'
                                          )
        end
      end
    end

    context 'with invalid params' do
      let!(:params) { { type: 'Invalid Type' } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createAddressBook)
        expect(response.address_book).to be_nil
        expect(errors).to eq(["'Invalid Type' is not a valid type"])
      end
    end

    context 'without permissions' do
      let!(:manager_commercialization) { create(:user, :manager_commercialization) }
      let!(:params) { { type: :investor } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: manager_commercialization, key: :createAddressBook)
        expect(response.address_book).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def address
    <<~ADDRESS
      address: {
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
        createAddressBook(
          input: {
            attributes: {
              projectId: "#{project.id}"
              type: "#{args[:type]}"
              displayName: "#{args[:display_name]}"
              name: "Philips"
              additionalName: "Jordan"
              company: "Charlotte Hornets"
              language: "D"
              phone: "099292922"
              mobile: "03393933"
              email: "philips.jordan@chornets.us"
              website: "charlotte-hornets.com"
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
