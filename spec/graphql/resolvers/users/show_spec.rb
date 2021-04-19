# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::User, '#show' do
  let_it_be(:team_expert) { create(:user, :team_expert) }
  let_it_be(:address) { create(:address, addressable: team_expert) }

  describe '.resolve' do
    context 'without id' do
      it 'returns current user details' do
        user, errors = formatted_response(query, current_user: team_expert, key: :user)
        expect(user).to have_attributes(
          email: team_expert.email,
          id: team_expert.id,
          name: username(team_expert)
        )

        profile = user.profile
        expect(profile).to have_attributes(
          firstname: profile.firstname,
          lastname: profile.lastname,
          salutation: profile.salutation,
          phone: profile.phone,
          department: profile.department
        )

        address = user.address
        expect(address).to have_attributes(
          streetNo: address.streetNo,
          street: address.street,
          zip: address.zip,
          city: address.city
        )

        expect(errors).to be_nil
      end
    end

    context 'with id' do
      let!(:another_user) { create(:user, :team_standard) }

      it 'returns details of the given user' do
        user, errors = formatted_response(query(id: another_user.id), current_user: team_expert, key: :user)
        expect(user).to have_attributes(
          email: another_user.email,
          id: another_user.id,
          name: username(another_user)
        )

        expect(errors).to be_nil
      end
    end

    context "when record doesn't exist" do
      it 'responds with error' do
        response, errors = formatted_response(
          query(id: '16c85b18-473d-4f5d-9ab4-666c7faceb6c\"'), current_user: team_expert
        )

        expect(response.user).to be_nil
        expect(errors[0]).to include("Couldn't find Telco::Uam::User with 'id'=16c85b18-473d-4f5d-9ab4-666c7faceb6c\"")
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        user#{query_string(args)} {
          id
          email
          name
          profile {
            firstname
            lastname
            salutation
            phone
            department
          }
          address {
            streetNo
            street
            city
            zip
          }
        }
      }
    GQL
  end

  def query_string(args = {})
    args[:id].present? ? "(id: \"#{args[:id]}\")" : nil
  end
end
