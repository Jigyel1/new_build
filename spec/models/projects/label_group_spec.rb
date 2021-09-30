# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::LabelGroup, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:label_group).optional(true) }
  end

  describe 'validations' do
    it 'validates uniqueness of label list' do
      subject = build(:projects_label_group, label_list: 'aa, Aa ', project: create(:project))
      expect(subject).to be_invalid
      expect(subject.errors.full_messages).to eq([t('activerecord.errors.models.admin_toolkit/label_group.labels_not_unique')])
    end
  end

  describe 'getters' do
    let_it_be(:label_group) { create(:admin_toolkit_label_group, label_list: 'Assign KAM, Offer Needed') }

    context "without it's own labels" do
      subject { create(:projects_label_group, project: create(:project), label_group: label_group) }

      it { is_expected.to have_attributes(label_list: []) }
    end

    context "with it's own labels" do
      subject(:project_label_group) do
        create(
          :projects_label_group,
          project: create(:project),
          label_group: label_group,
          label_list: 'More Information Requested, Management Decision Meeting'
        )
      end

      it do
        expect(project_label_group).to have_attributes(label_list: ['More Information Requested',
                                                                    'Management Decision Meeting'])
      end
    end
  end
end
