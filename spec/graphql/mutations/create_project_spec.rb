# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateProject do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :create }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_region) { create(:kam_region) }

  before_all do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: create(:admin_toolkit_footprint_type),
      footprint_apartment: create(:admin_toolkit_footprint_apartment, index: 1, min: 6, max: 10)
    )

    create(
      :admin_toolkit_penetration,
      :hfc_footprint,
      zip: '8008',
      kam_region: kam_region,
      penetration_competitions: [build(:penetration_competition, competition: create(:admin_toolkit_competition))]
    )
  end

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { status: 'Technical Analysis', move_in_starts_on: Date.current } }

      it 'creates the project' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(errors).to be_nil

        expect(response.project).to have_attributes(
          internalId: 'e922833',
          moveInStartsOn: Date.current.date_str,
          status: 'technical_analysis',
          assigneeType: 'nbo',
          apartmentsCount: 10,
          buildingsCount: 3,
          category: 'standard'
        )

        expect(response.project.kamRegion).to have_attributes(id: kam_region.id, name: kam_region.name)
        expect(response.project.assignee).to have_attributes(id: kam.id, name: kam.name)

        project = Project.find(response.project.id)
        expect(project).to have_attributes(
          gis_url: "#{Rails.application.config.gis_manual_url}",
        )
      end

      it 'creates the associated address books' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(errors).to be_nil
        address_books = response.project.addressBooks

        record = address_books.find { _1[:type] == 'investor' }
        expect(OpenStruct.new(record)).to have_attributes(
          name: 'Philips',
          company: 'Charlotte Hornets',
          phone: '099292922',
          mobile: '03393933',
          language: 'de',
          email: 'philips.jordan@chornets.us',
          website: 'charlotte-hornets.com'
        )

        record = address_books.find { _1[:type] == 'architect' }
        expect(OpenStruct.new(record)).to have_attributes(
          name: 'Isiah',
          company: 'Detroit Pistons',
          language: 'it',
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
        expect(buildings.pluck(:apartments_count)).to match_array([3, 3, 4])
      end

      it 'creates a label group for the project itself' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(errors).to be_nil

        project = Project.find(response.project.id)
        expect(project.label_groups.size).to eq(1)
        expect(project.label_groups.first).to have_attributes(
          system_generated: true,
          label_list: [Hooks::Project::MANUALLY_CREATED]
        )
      end
    end

    context 'when assignee is not a KAM' do
      let!(:team_expert) { create(:user, :team_expert) }
      let!(:params) { { assignee_id: team_expert.id, status: 'Technical Analysis' } }

      it 'sets the assignee type as NBO project' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(errors).to be_nil
        expect(response.project.assigneeType).to eq('nbo')
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
        response, errors = formatted_response(query(params), current_user: manager_commercialization,
                                                             key: :createProject)
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
              internalId: "e922833"
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
            id status category internalId moveInStartsOn assigneeType apartmentsCount buildingsCount
            assignee { id name }
            addressBooks { id type name company language email website phone mobile
            address { id street city zip} }
            kamRegion { id name }
          }
        }
      }
    GQL
  end
end
