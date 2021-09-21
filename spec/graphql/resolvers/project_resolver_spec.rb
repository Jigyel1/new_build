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
                                  name: project.name,
                                  entryType: 'manual'
                                )

        expect(data.project.address).to have_attributes(
                                          street: address.street,
                                          city: address.city,
                                          zip: address.zip
                                        )

        expect(data.project.projectNr).to start_with('2')

        expect(OpenStruct.new(data.project.states.to_h)).to have_attributes(
                                         open: true,
                                         technical_analysis: false,
                                         technical_analysis_completed: false,
                                         ready_for_offer: false
                                       )
      end
    end

    context 'for prio 1 projects' do
      before { allow_any_instance_of(Projects::StateMachine).to receive(:prio_one?).and_return(true) }

      it 'returns project states without technical analysis completed state' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(OpenStruct.new(data.project.states.to_h)).to have_attributes(
                                                              open: true,
                                                              technical_analysis: false,
                                                              ready_for_offer: false
                                                            )
      end
    end

    context 'when project has reached ready for offer' do
      before { project.update_column(:status, :ready_for_offer) }

      it 'returns project status accordingly' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(OpenStruct.new(data.project.states.to_h)).to have_attributes(
                                                              open: true,
                                                              technical_analysis: true,
                                                              technical_analysis_completed: true,
                                                              ready_for_offer: true
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
          project(id: "#{project.id}") 
          { id name projectNr entryType states address { street city zip } } 
        }
    GQL
  end
end
