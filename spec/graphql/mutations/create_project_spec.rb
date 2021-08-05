# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateProject do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) {{ status: 'Technical Analysis', move_in_starts_on: Date.current }}

      it 'creates the project' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(errors).to be_nil
        expect(response.project).to have_attributes(
          externalId: 'e922833',
          moveInStartsOn: Date.current.in_time_zone.date_str,
          status: 'Technical Analysis',
          assignee: nil,
          assignee_type: 'NBO Project'
        )
      end

      it 'creates the associated address books' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(errors).to be_nil
        address_books = response.project.addressBooks

        record = address_books.find { |address_book| address_book[:type] == 'Investor' }
        expect(OpenStruct.new(record)).to have_attributes(
          name: 'Philips',
          company: 'Charlotte Hornets',
          phone: '099292922',
          mobile: '03393933',
          email: 'philips.jordan@chornets.us',
          website: 'charlotte-hornets.com'
        )

        record = address_books.find { |address_book| address_book[:type] == 'Architect' }
        expect(OpenStruct.new(record)).to have_attributes(
          name: 'Isiah',
          company: 'Detroit Pistons',
          language: 'EN',
          phone: '049292922',
          mobile: '103393933',
          email: 'isiah.thomas@pistons.us',
          website: 'detroit-pistons.com'
        )
      end
    end

    context 'when the project has more than 50 apartments' do
      let!(:params) {{ status: 'Technical Analysis', apartments: 51 }}

      context 'and has a KAM assigned for the region' do
        let!(:kam_region) { create(:admin_toolkit_kam_region, kam: kam) }
        let!(:penetration) { create(:admin_toolkit_penetration, zip: '8008', kam_region: kam_region) }

        it 'sets the KAM as assignee for the project' do
          response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
          expect(errors).to be_nil
          expect(response.project.assignee).to have_attributes(
                                                 id: kam.id,
                                                 name: kam.name
                                      )
        end
      end

      context 'but has no KAM assigned for the region' do
        it 'does not set an assignee for the project' do
          response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
          expect(errors).to be_nil
          expect(response.project.assignee).to be_nil
        end
      end
    end

    context 'with invalid params' do
      let!(:params) { { status: 'Invalid Status' } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(response.project).to be_nil
        expect(errors).to eq(["'Invalid Status' is not a valid status"])
      end
    end

    context 'without permissions' do
      let!(:params) {{ status: 'Technical Analysis' }}

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :createProject)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def address
    <<~ADDRESS
      address: {
        street: "#{Faker::Address.street_name}",
        streetNo: "#{Faker::Address.building_number}"
        city: "#{Faker::Address.city}"
        zip: "8008"
      }
    ADDRESS
  end

  def address_books
    <<~ADDRESS_BOOKS
      addressBooks: [
        {
          type: "Investor"
          name: "Philips"
          additionalName: "Jordan"
          company: "Charlotte Hornets"
          language: "DE"
          phone: "099292922"
          mobile: "03393933"
          email: "philips.jordan@chornets.us"
          website: "charlotte-hornets.com"
          #{address}
        },
        {
          type: "Architect"
          name: "Isiah"
          additionalName: "Thomas"
          company: "Detroit Pistons"
          language: "EN"
          phone: "049292922"
          mobile: "103393933"
          email: "isiah.thomas@pistons.us"
          website: "detroit-pistons.com"
          #{address}
        }
      ]
    ADDRESS_BOOKS
  end

  def query(args = {})
    apartments = args[:apartments] || 10
    move_in_starts_on = args[:move_in_starts_on] || Date.current

    <<~GQL
      mutation {
        createProject(
          input: {
            attributes: {
              name: "West ZentralSchweiz + Solothurn Offnet"
              externalId: "e922833"
              status: "#{args[:status]}"
              moveInStartsOn: "#{move_in_starts_on}"
              moveInEndsOn: "#{Date.current + 3.months}"
              constructionStartsOn: "#{Date.current - 3.years}"
              lotNumber: "EA0988833"
              buildings: 3
              apartments: #{apartments}
              #{address}
              #{address_books}
            }
          }
        )
        {
          project {
            id status externalId moveInStartsOn assignee { id name }
            addressBooks { id type name company language email website phone mobile address { id street city zip} }
          }
        }
      }
    GQL
  end
end
