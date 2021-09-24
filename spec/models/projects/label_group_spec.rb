# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::LabelGroup, type: :model do
  describe 'getters' do
    let_it_be(:label_group) { create(:admin_toolkit_label_group, label_list: 'Assign KAM, Offer Needed') }

    context "without it's own labels" do
      subject { create(:projects_label_group, project: create(:project), label_group: label_group) }

      it { is_expected.to have_attributes(label_list: []) }
    end

    context "with it's own labels" do
      subject do
        create(
          :projects_label_group,
          project: create(:project),
          label_group: label_group,
          label_list: 'More Information Requested, Management Decision Meeting'
        )
      end

      it do
        expect(subject).to have_attributes(
          label_list: ['More Information Requested', 'Management Decision Meeting', 'Manually Created']
        )
      end
    end
  end
end
