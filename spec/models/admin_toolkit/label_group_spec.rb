# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::LabelGroup, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it do
      subject = create(:admin_toolkit_label_group)
      expect(subject).to validate_uniqueness_of(:name)
    end
  end
end
