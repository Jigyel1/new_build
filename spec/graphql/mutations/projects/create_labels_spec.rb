# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::CreateLabels do
  let_it_be(:label_group) { create(:admin_toolkit_label_group, label_list: 'Assign KAM, Offer Needed') }
  let_it_be(:project) { create(:project, :from_info_manager) }
  let_it_be(:params) { { label_list: 'Prio 3, On Hold' } }

  describe '.resolve' do
    context 'with permissions' do
      it 'updates the label list' do
        response, errors = formatted_response(query(params), current_user: create(:user, :super_user),
                                                             key: :createProjectLabels)
        expect(errors).to be_nil
        expect(response.labelGroup.labelList).to match_array(['Prio 3', 'On Hold'])
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: create(:user, :kam),
                                                             key: :createProjectLabels)
        expect(response.labelGroup).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        createProjectLabels(
          input: {
            attributes: {
              projectId: "#{project.id}"
              labelGroupId: "#{label_group.id}"
              labelList: "#{args[:label_list]}"
            }
          }
        )
        { labelGroup { id labelList } }
      }
    GQL
  end
end
