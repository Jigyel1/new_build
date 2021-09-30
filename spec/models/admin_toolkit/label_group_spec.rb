# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::LabelGroup, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it do
      subject = create(:admin_toolkit_label_group)
      expect(subject).to validate_uniqueness_of(:name)
    end

    it 'validates uniqueness of label list' do
      subject = build(:admin_toolkit_label_group, label_list: 'aa, Aa ')
      expect(subject).to be_invalid
      expect(subject.errors.full_messages).to eq([t('activerecord.errors.models.admin_toolkit/label_group.labels_not_unique')])
    end
  end
end
