# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateProject do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { status: 'Technical Analysis', move_in_starts_on: Date.current } }

      it 'creates the project' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(errors).to be_nil
        expect(response.project).to have_attributes(
          externalId: 'e922833',
          moveInStartsOn: Date.current.in_time_zone.date_str,
          status: 'Technical Analysis',
          assigneeType: 'KAM Project',
          apartmentsCount: 10,
          buildingsCount: 3
        )

        expect(response.project.assignee).to have_attributes(
                                               id: kam.id,
                                               name: kam.name
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
                                            language: 'D',
                                            email: 'philips.jordan@chornets.us',
                                            website: 'charlotte-hornets.com'
                                          )

        record = address_books.find { |address_book| address_book[:type] == 'Architect' }
        expect(OpenStruct.new(record)).to have_attributes(
                                            name: 'Isiah',
                                            company: 'Detroit Pistons',
                                            language: 'I',
                                            phone: '049292922',
                                            mobile: '103393933',
                                            email: 'isiah.thomas@pistons.us',
                                            website: 'detroit-pistons.com'
                                          )
      end

      it 'creates associated apartments and buildings' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(errors).to be_nil

        buildings = Project.find(response.project.id).buildings
        expect(buildings.count).to eq(3)
        expect(buildings.pluck(:apartments_count)).to match_array([3,3,4])
      end
    end

    context 'when assignee is not a KAM' do
      let!(:team_expert) { create(:user, :team_expert) }
      let!(:params) { { assignee_id: team_expert.id, status: 'Technical Analysis' } }

      it 'sets the assignee type as NBO project' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(errors).to be_nil
        expect(response.project.assigneeType).to eq('NBO Project')
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
      let!(:manager_commercialization) { create(:user, :manager_commercialization) }
      let!(:params) { { status: 'Technical Analysis' } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: manager_commercialization, key: :createProject)
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
          language: "D"
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
          language: "I"
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
    assignee_id = args[:assignee_id] || kam.id

    <<~GQL
      mutation {
        createProject(
          input: {
            attributes: {
              name: "West ZentralSchweiz + Solothurn Offnet"
              assigneeId: "#{assignee_id}"
              externalId: "e922833"
              status: "#{args[:status]}"
              moveInStartsOn: "#{move_in_starts_on}"
              moveInEndsOn: "#{Date.current + 3.months}"
              constructionStartsOn: "#{Date.current - 3.years}"
              lotNumber: "EA0988833"
              buildingsCount: 3
              apartmentsCount: #{apartments}
              #{address}
              #{address_books}
            }
          }
        )
        {
          project {
            id status externalId moveInStartsOn assigneeType apartmentsCount buildingsCount assignee { id name }
            addressBooks { id type name company language email website phone mobile address { id street city zip} }
          }
        }
      }
    GQL
  end
end
