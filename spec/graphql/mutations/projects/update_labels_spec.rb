# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UpdateLabels do
  let_it_be(:label_group) { create(:admin_toolkit_label_group, label_list: 'Assign KAM, Offer Needed') }
  let_it_be(:project) { create(:project, :from_info_manager) }
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }

  let_it_be(:projects_label_group) do
    create(
      :projects_label_group,
      label_group: label_group,
      project: project,
      label_list: 'Prio 1, Prio 2'
    )
  end

  let_it_be(:params) { { id: project.id, label_list: 'Prio 3, On Hold' } }

  describe '.resolve' do
    context 'for admins' do
      it 'updates the label list' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateProjectLabels)
        expect(errors).to be_nil
        expect(response.labelGroup.labelList).to match_array(['Prio 3', 'On Hold'])
      end
    end

    context 'for system generated label group' do
      before { projects_label_group.update_column(:system_generated, true) }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateProjectLabels)
        expect(response.labelGroup).to be_nil
        expect(errors).to eq([t('projects.label_group.system_generated')])
      end
    end

    context 'for non admins' do
      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateProjectLabels)
        expect(response.labelGroup).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateProjectLabels(
          input: {
            attributes: {
              id: "#{projects_label_group.id}"
              labelList: "#{args[:label_list]}"
            }
          }
        )
        { labelGroup { id labelList labelGroup { id name } } }
      }
    GQL
  end
end
