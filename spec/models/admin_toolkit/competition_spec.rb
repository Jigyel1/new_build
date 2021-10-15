# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminToolkit::Competition, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:factor) }
    it { is_expected.to validate_presence_of(:lease_rate) }
    it { is_expected.to validate_numericality_of(:factor).is_greater_than_or_equal_to(0) }

    it do
      expect(create(:admin_toolkit_competition)).to validate_uniqueness_of(:name).ignoring_case_sensitivity
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:penetration_competitions).dependent(:destroy) }
  end
end
