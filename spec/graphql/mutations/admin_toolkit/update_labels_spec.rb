# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateLabels do
  let_it_be(:label_group) { create(:admin_toolkit_label_group, label_list: 'Prio 1, Prio 2') }

  describe '.resolve' do
    context 'for admins' do
      let!(:params) { { label_group_id: label_group.id, label_list: 'Prio 3, On Hold' } }

      it 'updates the label list' do
        response, errors = formatted_response(query(params), current_user: create(:user, :super_user),
                                                             key: :updateLabel)
        expect(errors).to be_nil
        expect(response.labelGroup.labelList).to match_array(['Prio 3', 'On Hold'])
      end
    end

    context 'for non admins' do
      let!(:params) { { label_group_id: label_group.id, label_list: 'Assign kam' } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: create(:user, :kam), key: :updateLabel)
        expect(response.labelGroup).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateLabel(
          input: {
            attributes: {
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
