# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::PctMonth, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:min) }
    it { is_expected.to validate_presence_of(:max) }
    it { is_expected.to validate_presence_of(:index) }

    it do
      subject = create(:admin_toolkit_pct_month)
      expect(subject).to validate_uniqueness_of(:index)
    end

    it { is_expected.to validate_numericality_of(:min).only_integer.is_greater_than_or_equal_to(0) }
  end
end
