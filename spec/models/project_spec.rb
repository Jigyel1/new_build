# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'getters' do
    let_it_be(:label_group) { create(:admin_toolkit_label_group, label_list: 'Assign KAM, Offer Needed') }

    context "without it's own labels" do
      subject { create(:project) }
      it { is_expected.to have_attributes(label_list: ['Assign KAM', 'Offer Needed']) }
    end

    context "with it's own labels" do
      subject { create(:project, label_list: 'More Information Requested, Management Decision Meeting') }

      it do
        is_expected.to have_attributes(
                         label_list: ['More Information Requested', 'Management Decision Meeting', 'Manually Created']
                       )
      end
    end
  end
end
