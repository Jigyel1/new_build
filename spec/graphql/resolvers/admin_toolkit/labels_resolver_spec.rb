# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::LabelsResolver do
  let_it_be(:label_group) { create(:admin_toolkit_label_group, label_list: 'Prio 1, Prio 2') }

  let_it_be(:label_group_b) do
    create(:admin_toolkit_label_group,
           :technical_analysis_completed,
           name: 'Contract',
           label_list: 'Prio 1, Prio 2, On Hold')
  end

  describe '.resolve' do
    context 'for admins' do
      let_it_be(:super_user) { create(:user, :super_user) }

      it 'returns all label groups' do
        response, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(response.adminToolkitLabels.pluck(:id)).to match_array(
          [
            label_group.id, label_group_b.id
          ]
        )
      end
    end

    context 'for non admins' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam)
        expect(response.adminToolkitLabels).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      query { adminToolkitLabels { id labelList name code } }
    GQL
  end
end
