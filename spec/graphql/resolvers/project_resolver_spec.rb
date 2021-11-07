# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::ProjectResolver do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :read }) }
  let_it_be(:address) { build(:address) }
  let_it_be(:project) { create(:project, :with_access_tech_cost, :with_installation_detail, address: address) }
  let_it_be(:label_group) { create(:admin_toolkit_label_group, :open, label_list: 'Assign KAM, Offer Needed') }

  let_it_be(:projects_label_group) do
    create(
      :projects_label_group,
      label_group: label_group,
      project: project,
      label_list: 'Prio 1, Prio 2'
    )
  end

  describe '.resolve' do
    context 'with read permission' do
      it 'returns project details' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil

        expect(data.project).to have_attributes(
          id: project.id,
          name: project.name,
          entryType: 'manual'
        )

        expect(data.project.projectNr).to start_with('2')

        expect(data.project.states.to_h).to eq(
          open: true,
          technical_analysis: false,
          technical_analysis_completed: false,
          ready_for_offer: false,
          commercialization: false
        )
      end

      it 'returns proper associations' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil

        expect(data.project.address).to have_attributes(
          street: address.street,
          city: address.city,
          zip: address.zip
        )

        expect(data.project.accessTechCost).to have_attributes(
          hfcOnPremiseCost: 9.99,
          hfcOffPremiseCost: 9.99,
          lwlOnPremiseCost: 9.99,
          lwlOffPremiseCost: 9.99
        )
      end

      it 'returns proper project labels' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil

        expect(data.project.defaultLabelGroup).to have_attributes(
          systemGenerated: true,
          labelList: ['Manually Created']
        )

        expect(data.project.currentLabelGroup).to have_attributes(
          systemGenerated: false,
          labelList: ['Prio 1', 'Prio 2']
        )
      end
    end

    context 'for prio 1 projects' do
      before do
        create(
          :admin_toolkit_pct_value,
          :prio_one,
          pct_month: create(:admin_toolkit_pct_month, min: 10, max: 17),
          pct_cost: create(:admin_toolkit_pct_cost, min: 1187, max: 100_000)
        )

        create(:projects_pct_cost, project: project, payback_period: 15)
      end

      it 'returns project states without technical analysis completed state' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(data.project.states.to_h).to eq(
          open: true,
          technical_analysis: false,
          ready_for_offer: false,
          commercialization: false
        )
      end
    end

    context 'for marketing_only projects' do
      before { project.update_column(:category, :marketing_only) }

      it 'returns project states without TAC & ready for offer state' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(data.project.states.to_h).to eq(
          open: true,
          technical_analysis: false,
          commercialization: false
        )
      end
    end

    context 'when project has reached ready for offer' do
      before { project.update_column(:status, :ready_for_offer) }

      it 'returns project status accordingly' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(data.project.states.to_h).to eq(
          open: true,
          technical_analysis: true,
          technical_analysis_completed: true,
          ready_for_offer: true,
          commercialization: false
        )
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
      query
        {
          project(id: "#{project.id}") {
            id name projectNr entryType states accessTechnology analysis
            inHouseInstallation standardCostApplicable
            competition { id name }
            defaultLabelGroup { systemGenerated labelList }
            currentLabelGroup { systemGenerated labelList }
            address { street city zip }
            installationDetail { sockets builder }
            accessTechCost { hfcOnPremiseCost hfcOffPremiseCost lwlOnPremiseCost  lwlOffPremiseCost comment explanation }
          }
        }
    GQL
  end
end
